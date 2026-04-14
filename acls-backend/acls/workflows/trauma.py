from django.utils.translation import gettext_lazy as _

TRAUMA_WORKFLOW = {
    "trauma_start": {
        "title": _("Step 1: Stop Bleeding"),
        "question": _("Is the patient bleeding a lot? Press hard on the wound with a clean cloth. Use a bandage if you have one. Done?"),
        "video": "/static/images/pulse_check.png",
        "choices": [
            {"label": _("YES, bleeding stopped"), "next": "trauma_check", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "trauma_check": {
        "title": _("Step 2: Airway & Breathing"),
        "question": _("Check if the patient is breathing. If their neck is hurt, do NOT move their head. Hold their head still. Ready?"),
        "video": "/static/images/trauma_primary.png",
        "choices": [
            {"label": _("I am holding the head still"), "next": "trauma_hospital", "color": "primary"},
        ]
    },
    "trauma_hospital": {
        "title": _("Step 3: Go to Hospital"),
        "question": _("Keep the patient warm and take them to the hospital fast in the ambulance!"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("Going to hospital now"), "next": "dashboard", "color": "success", "isExit": True},
        ]
    }
}
