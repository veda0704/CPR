from django.urls import path
from . import api_views

urlpatterns = [
    # API Endpoints for React Frontend
    path("dashboard/", api_views.api_dashboard_data, name="api_dashboard"),
    path("step/<str:step_id>/", api_views.api_get_step, name="api_step"),
    path("tts-text/", api_views.api_tts_text, name="api_tts_text"),
    path("sync-all/", api_views.api_bulk_sync, name="api_sync_all"),
    path("stream-video/<path:video_path>", api_views.stream_video, name="stream_video"),
]
