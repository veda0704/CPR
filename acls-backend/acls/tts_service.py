import requests
import os
import hashlib
from django.conf import settings
from urllib.parse import quote

class TTSService:
    @staticmethod
    def generate_audio(text, language_code='en'):
        """
        Generates audio for given text using Google Translate's unofficial TTS API.
        """
        if not text:
            return None

        # Clean text for URL
        clean_text = text.strip().replace('\n', ' ')
        
        # Determine language (support en and te)
        lang = 'en'
        if language_code and language_code.startswith('te'):
            lang = 'te'
        
        # Create a unique filename based on text and lang
        hash_input = f"{clean_text}_{lang}".encode('utf-8')
        file_hash = hashlib.md5(hash_input).hexdigest()
        filename = f"{file_hash}.mp3"
        
        # Ensure static/audio directory exists
        audio_dir = os.path.join(settings.BASE_DIR, 'static', 'audio')
        if not os.path.exists(audio_dir):
            os.makedirs(audio_dir)
            
        file_path = os.path.join(audio_dir, filename)
        file_url = f"{settings.STATIC_URL}audio/{filename}"

        # If file already exists, return it
        if os.path.exists(file_path):
            return file_url

        try:
            # Google Translate TTS URL format (client=tw-ob works without token)
            url = f"https://translate.google.com/translate_tts?ie=UTF-8&q={quote(clean_text)}&tl={lang}&client=tw-ob"
            
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            }
            
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            with open(file_path, "wb") as f:
                f.write(response.content)
                    
            return file_url
                
        except Exception as e:
            print(f"Google TTS Error: {e}")
            return None
