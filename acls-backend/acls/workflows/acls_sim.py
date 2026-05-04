from django.utils.translation import gettext_lazy as _

ACLS_SIM_WORKFLOW = {
    "1": {
        "title": _("Scene Safety"),
        "question": _("Is the scene safe for you and your team?"),
        "video": "/static/videos/check.mp4",
        "choices": [
            {"label": _("YES"), "next": "2", "color": "primary"},
            {"label": _("NO"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "2": {
        "title": _("Responsiveness"),
        "question": _("Is the patient responsive? (Tap and shout)"),
        "video": "/static/videos/responsive_2.mp4",
        "choices": [
            {"label": _("YES"), "next": "dashboard", "color": "secondary", "isExit": True},
            {"label": _("NO"), "next": "3", "color": "primary"}
        ]
    },
    "3": {
        "title": _("Witnessed Collapse"),
        "question": _("Did anyone see the person collapse?"),
        "video": "/static/videos/Collapsed.mp4",
        "choices": [
            {"label": _("YES"), "next": "4", "color": "primary"},
            {"label": _("NO"), "next": "4", "color": "primary"}
        ]
    },
    "4": {
        "title": _("Breathing Check"),
        "question": _("Is the patient breathing normally?"),
        "video": "/static/videos/Breathing.mp4",
        "choices": [
            {"label": _("YES"), "next": "5", "color": "primary"},
            {"label": _("NO"), "next": "5", "color": "primary"}
        ]
    },
    "5": {
        "title": _("Pulse Check"),
        "question": _("Is a pulse present (within 10 seconds)?"),
        "video": "/static/videos/Pulse.mp4",
        "time_limit": 10,
        "timeout_next": "6",
        "choices": [
            {"label": _("YES"), "next": "alg_brady_assess", "color": "primary"},
            {"label": _("NO"), "next": "6", "color": "primary"}
        ]
    },
    "6": {
        "title": _("Start CPR"),
        "question": _("Start high-quality CPR (30 compressions, 2 breaths)?"),
        "video": "/static/videos/CPR.mp4",
        "choices": [
            {"label": _("YES"), "next": "7", "color": "primary"},
            {"label": _("NO"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "7": {
        "title": _("Monitor/Defibrillator"),
        "question": _("Is a defibrillator / cardiac monitor available?"),
        "video": "/static/videos/shock.mp4",
        "choices": [
            {"label": _("YES"), "next": "8", "color": "primary"},
            {"label": _("NO"), "next": "8", "color": "primary"}
        ]
    },
    "8": {
        "title": _("Rhythm Check"),
        "question": _("Look at the monitor. Is the rhythm shockable (VF/VT)?"),
        "video": "/static/videos/check.mp4",
        "choices": [
            {"label": _("YES (SHOCKABLE)"), "next": "vf_workflow", "color": "danger"},
            {"label": _("NO (NON-SHOCKABLE)"), "next": "asystole_workflow", "color": "warning"},
            {"label": _("ROSC ACHIEVED"), "next": "alg_post_arrest_start", "color": "success"}
        ]
    }
}
