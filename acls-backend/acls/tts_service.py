import os
import hashlib
from urllib.parse import quote
import requests
from django.conf import settings

class TTSService:
    @staticmethod
    def generate_audio(text, language_code='en'):
        """
        Generates audio for given text using Google Cloud Text-to-Speech when configured.
        Falls back to the existing Google Translate endpoint only if no official credentials are available.
        """
        if not text:
            return None

        clean_text = text.strip().replace('\n', ' ')
        lang = 'en'
        if language_code and language_code.startswith('te'):
            lang = 'te'

        hash_input = f"{clean_text}_{lang}".encode('utf-8')
        file_hash = hashlib.md5(hash_input).hexdigest()
        filename = f"{file_hash}.mp3"

        # Use media directory instead of static for better production deployment
        audio_dir = os.path.join(settings.MEDIA_ROOT, 'tts_audio')
        os.makedirs(audio_dir, exist_ok=True)

        file_path = os.path.join(audio_dir, filename)
        file_url = f"{settings.MEDIA_URL}tts_audio/{filename}"

        if os.path.exists(file_path):
            return file_url

        try:
            if TTSService._can_use_google_cloud():
                success = TTSService._generate_with_google_cloud(clean_text, lang, file_path)
            else:
                success = TTSService._generate_with_translate(clean_text, lang, file_path)
            
            if success and os.path.exists(file_path):
                return file_url
            else:
                print(f"TTS generation failed for text: {clean_text[:50]}...")
                return None
        except Exception as e:
            print(f"TTS generation failed: {e}")
            return None

    @staticmethod
    def _can_use_google_cloud():
        return bool(
            os.getenv('GOOGLE_APPLICATION_CREDENTIALS') or
            os.getenv('GOOGLE_CLOUD_PROJECT') or
            os.getenv('GCLOUD_PROJECT')
        )

    @staticmethod
    def _generate_with_google_cloud(clean_text, lang, file_path):
        try:
            from google.cloud import texttospeech
        except (ImportError, TypeError) as e:
            print(f"Google Cloud SDK unavailable (protobuf compatibility issue): {e}")
            print("Falling back to Google Translate TTS endpoint...")
            return TTSService._generate_with_translate(clean_text, lang, file_path)
        
        try:
            client = texttospeech.TextToSpeechClient()
            input_text = texttospeech.SynthesisInput(text=clean_text)
            voice = texttospeech.VoiceSelectionParams(
                language_code='te-IN' if lang == 'te' else 'en-US',
                ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL,
            )
            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3,
            )
            response = client.synthesize_speech(
                input=input_text,
                voice=voice,
                audio_config=audio_config,
            )
            with open(file_path, 'wb') as audio_file:
                audio_file.write(response.audio_content)
            return True
        except Exception as e:
            print(f"Google Cloud TTS failed: {e}, falling back to Google Translate...")
            return TTSService._generate_with_translate(clean_text, lang, file_path)

    @staticmethod
    def _generate_with_translate(clean_text, lang, file_path):
        try:
            url = f"https://translate.google.com/translate_tts?ie=UTF-8&q={quote(clean_text)}&tl={lang}&client=tw-ob"
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            with open(file_path, 'wb') as f:
                f.write(response.content)
            return True
        except Exception as e:
            print(f"Google Translate TTS failed: {e}")
            return False
