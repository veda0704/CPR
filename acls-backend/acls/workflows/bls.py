from django.utils.translation import gettext_lazy as _

BLS_WORKFLOW = {
    "bls_start": {
        "title": _("Step 1: Response Check"),
        "question": _("Tap the patient and shout. Are they awake?"),
        "video": "/static/videos/responsive_2.mp4",
        "choices": [
            {"label": _("YES, they are awake"), "next": "dashboard", "color": "success", "isExit": True},
            {"label": _("NO, they are not awake"), "next": "bls_pulse", "color": "danger"}
        ]
    },
    "bls_pulse": {
        "title": _("Step 2: Pulse & Breathing"),
        "question": _("Check if they are breathing and check for a pulse in the neck. Do they have a pulse?"),
        "video": "/static/videos/Pulse.mp4",
        "choices": [
            {"label": _("YES, pulse found"), "next": "dashboard", "color": "success", "isExit": True},
            {"label": _("NO pulse found"), "next": "bls_cpr", "color": "danger"}
        ]
    },
    "bls_cpr": {
        "title": _("Step 3: Start CPR"),
        "question": _("Push hard and fast on the center of the chest (30 times). Then give 2 breaths. Keep going!"),
        "video": "/static/videos/CPR.mp4",
        "choices": [
            {"label": _("CPR in progress"), "next": "dashboard", "color": "primary", "isExit": True}
        ]
    }
}
