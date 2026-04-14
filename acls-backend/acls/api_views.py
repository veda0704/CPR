from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .workflows import WORKFLOW_STEPS
from django.utils.translation import activate
from .tts_service import TTSService
import re
import os
from django.http import StreamingHttpResponse, Http404
from django.conf import settings
from .translation_service import translate_dict, translate_to_te

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def api_get_step(request, step_id):
    """
    Returns a single simulation step.
    """
    # Language is handled by LocaleMiddleware
    lang = getattr(request, 'LANGUAGE_CODE', 'en')
    
    step = WORKFLOW_STEPS.get(step_id)
    if not step:
        return Response({"error": f"Step {step_id} not found"}, status=404)
    
    # Check if TTS audio should be generated (defaults to true for simulation)
    tts = request.query_params.get('tts', 'true').lower() == 'true'
    
    # Raw strings from the workflow files
    raw_question = str(step.get("question", ""))
    
    # Translate questions for UI and audio
    question_text = translate_to_te(raw_question) if lang == 'te' else raw_question
    
    audio_url = None
    if tts:
        audio_url = TTSService.generate_audio(question_text, language_code=lang)
    
    step_payload = {
        "id": step_id,
        "title": step.get("title", ""),
        "question": question_text,
        "audio_url": audio_url,
        "video": step.get("video"),
        "interactive_component": step.get("interactive_component"),
        "interactive_props": step.get("interactive_props"),
        "time_limit": step.get("time_limit"),
        "timeout_next": step.get("timeout_next"),
        "choices": step.get("choices", [])
    }
    
    # translate_dict now handles lazy strings properly
    translated_payload = translate_dict(step_payload, lang)
    
    return Response(translated_payload)

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def api_tts_text(request):
    text = request.data.get("text")
    lang_code = getattr(request, 'LANGUAGE_CODE', 'en')
    
    audio_url = TTSService.generate_audio(text, language_code=lang_code)
    return Response({"audio_url": audio_url})

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def api_bulk_sync(request):
    """
    Returns every step in every workflow for offline use.
    """
    lang = getattr(request, 'LANGUAGE_CODE', 'en')
    
    serialized_steps = {}
    for step_id, step in WORKFLOW_STEPS.items():
        step_payload = {
            "id": step_id,
            "title": step.get("title", ""),
            "question": step.get("question", ""),
            "audio_url": None,
            "video": step.get("video"),
            "interactive_component": step.get("interactive_component"),
            "interactive_props": step.get("interactive_props"),
            "time_limit": step.get("time_limit"),
            "timeout_next": step.get("timeout_next"),
            "choices": step.get("choices", [])
        }
        serialized_steps[step_id] = translate_dict(step_payload, lang)
        
    return Response(serialized_steps)

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def api_dashboard_data(request):
    """
    Returns modules grouped into learning levels.
    """
    # Language handled by middleware
    from django.utils.translation import gettext_lazy as _
    
    levels = [
        {
            "id": "level1",
            "name": str(_("Level 1: Basic Life Saving")),
            "tag": str(_("START HERE")),
            "modules": [
                {"name": _("Scene Safety & PPE"), "id": "scene_safety", "start_step": "scene_safety_start"},
                {"name": _("Systematic ABCDE"), "id": "abcde", "start_step": "abcde_start"},
                {"name": _("BLS & CPR"), "id": "bls", "start_step": "bls_start"},
                {"name": _("Choking Management"), "id": "choking", "start_step": "choking_start"},
            ]
        },
        {
            "id": "level2",
            "name": str(_("Level 2: Emergency Management")),
            "tag": str(_("INTERMEDIATE")),
            "modules": [
                {"name": _("Airway Anatomy"), "id": "airway", "start_step": "airway_start"},
                {"name": _("Advanced Airway"), "id": "adv_airway", "start_step": "adv_airway_start"},
                {"name": _("Trauma & Bleeding"), "id": "trauma", "start_step": "trauma_start"},
                {"name": _("Poisoning Management"), "id": "poisoning", "start_step": "poisoning_start"},
                {"name": _("Snake Bite Management"), "id": "snake_bite", "start_step": "snake_bite_initial"},
                {"name": _("Stroke Assessment"), "id": "stroke", "start_step": "stroke_start"},
                {"name": _("Disaster Management"), "id": "disaster", "start_step": "disaster_start"},
                {"name": _("NLS & Delivery"), "id": "delivery", "start_step": "delivery_start"},
            ]
        },
        {
            "id": "level3",
            "name": str(_("Level 3: Advanced Cardiac (ACLS)")),
            "tag": str(_("ADVANCED")),
            "modules": [
                {"name": _("ECG Waves & Basics"), "id": "ecg", "start_step": "ecg_start"},
                {"name": _("Rhythms & Blocks"), "id": "rhythms", "start_step": "rhythms_start"},
                {"name": _("Cardiac Algorithms"), "id": "cardiac_alg", "start_step": "cardiac_alg_start"},
                {"name": _("Reversible Causes (H5T5)"), "id": "h5t5", "start_step": "h5t5_start"},
                {"name": _("Professional ACLS Simulator"), "id": "acls", "start_step": "1"},
            ]
        }
    ]

    lang = getattr(request, 'LANGUAGE_CODE', 'en')
    
    dashboard_payload = {
        "levels": levels,
        "modes": [str(_("Training")), str(_("Testing")), str(_("Certification"))]
    }
    
    translated_dashboard = translate_dict(dashboard_payload, lang)
    
    return Response(translated_dashboard)

def stream_video(request, video_path):
    """
    Serves a video file with support for HTTP Range requests.
    """
    file_path = os.path.join(settings.BASE_DIR, "static", video_path)
    if not os.path.exists(file_path):
        raise Http404("Video not found")

    file_size = os.path.getsize(file_path)
    content_type = "video/mp4"
    range_header = request.META.get("HTTP_RANGE", "").strip()
    range_match = re.search(r"bytes=(\d+)-(\d*)", range_header)

    if range_match:
        first_byte, last_byte = range_match.groups()
        first_byte = int(first_byte) if first_byte else 0
        last_byte = int(last_byte) if last_byte else file_size - 1
        if last_byte >= file_size:
            last_byte = file_size - 1
        length = last_byte - first_byte + 1
        
        def file_iterator(offset, length, chunk_size=81920):
            with open(file_path, "rb") as f:
                f.seek(offset)
                remaining = length
                while remaining > 0:
                    chunk = f.read(min(chunk_size, remaining))
                    if not chunk:
                        break
                    yield chunk
                    remaining -= len(chunk)

        response = StreamingHttpResponse(file_iterator(first_byte, length), status=206, content_type=content_type)
        response["Content-Range"] = f"bytes {first_byte}-{last_byte}/{file_size}"
    else:
        def file_iterator(chunk_size=81920):
            with open(file_path, "rb") as f:
                while True:
                    chunk = f.read(chunk_size)
                    if not chunk:
                        break
                    yield chunk

        response = StreamingHttpResponse(file_iterator(), content_type=content_type)
        response["Content-Length"] = str(file_size)

    response["Accept-Ranges"] = "bytes"
    return response
