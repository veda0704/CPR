from django.utils.translation import gettext_lazy as _

SCENE_SAFETY_WORKFLOW = {
    "scene_safety_start": {
        "title": _("Scene Safety Assessment"),
        "question": _("Is the immediate area safe for you and your team to enter?"),
        "video": "/static/videos/safetychecks.mp4",
        "choices": [
            {"label": _("YES, Area is safe"), "next": "scene_safety_victim_count", "color": "primary"},
            {"label": _("NO, Hazards present"), "next": "scene_safety_unsafe", "color": "danger"},
        ]
    },
    "scene_safety_unsafe": {
        "title": _("Unsafe Scene"),
        "question": _("Do NOT enter. Wait for specialized help (Fire, Police, or Hazmat)."),
        "video": "/static/images/scene_safety.png",
        "choices": [
            {"label": _("I am waiting"), "next": "scene_safety_start", "color": "warning"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True},
        ]
    },
    "scene_safety_victim_count": {
        "title": _("Victim Count"),
        "question": _("How many victims are present at the location?"),
        "video": "/static/images/ems_dispatch.png",
        "choices": [
            {"label": _("ONE victim"), "next": "scene_safety_ppe_gloves", "color": "primary"},
            {"label": _("MULTIPLE victims"), "next": "scene_safety_mci", "color": "warning"},
        ]
    },
    "scene_safety_mci": {
        "title": _("Multiple Victims"),
        "question": _("This is a Mass Casualty Incident (MCI). Ready to start triage?"),
        "video": "/static/images/ems_dispatch.png",
        "choices": [
            {"label": _("START TRIAGE"), "next": "scene_safety_triage", "color": "danger"},
        ]
    },
    "scene_safety_triage": {
        "title": _("Triage Process"),
        "question": _("Sort patients based on priority (Red, Yellow, Green, Black). Move all walking wounded to a safe area. Done?"),
        "video": "/static/images/ems_dispatch.png",
        "choices": [
            {"label": _("DONE, patients sorted"), "next": "scene_safety_notify", "color": "primary"},
        ]
    },
    "scene_safety_notify": {
        "title": _("Notify Control Room"),
        "question": _("Report the situation and victim count to dispatch. Request additional backup if needed. Ready?"),
        "video": "/static/images/ems_dispatch.png",
        "choices": [
            {"label": _("YES, dispatch notified"), "next": "scene_safety_ppe_gloves", "color": "primary"},
        ]
    },
    "scene_safety_ppe_gloves": {
        "title": _("Protection: Gloves"),
        "question": _("Are you wearing gloves?"),
        "video": "/static/images/gloves.png",
        "choices": [
            {"label": _("YES"), "next": "scene_safety_ppe_barrier", "color": "primary"},
        ]
    },
    "scene_safety_ppe_barrier": {
        "title": _("Protection: Face Shield"),
        "question": _("Is a face shield or protective barrier available?"),
        "video": "/static/images/mask.png",
        "choices": [
            {"label": _("YES, wearing"), "next": "scene_safety_ppe_risk", "color": "primary"},
            {"label": _("NO, not available"), "next": "scene_safety_ppe_risk", "color": "warning"},
        ]
    },
    "scene_safety_ppe_risk": {
        "title": _("Risk Assessment"),
        "question": _("Are there any risks of body fluid splash or infection?"),
        "video": "/static/images/safetychecks.mp4",
        "choices": [
            {"label": _("YES, high risk"), "next": "scene_safety_ppe_advanced", "color": "danger"},
            {"label": _("NO, low risk"), "next": "scene_safety_ready", "color": "primary"},
        ]
    },
    "scene_safety_ppe_advanced": {
        "title": _("Advanced PPE"),
        "question": _("Wear a gown, N95 mask, and eye protection. Ready?"),
        "video": "/static/images/safetychecks.mp4",
        "choices": [
            {"label": _("YES, fully protected"), "next": "scene_safety_ready", "color": "primary"},
        ]
    },
    "scene_safety_ready": {
        "title": _("Scene Ready"),
        "question": _("Scene is safe and you are protected. Proceed to patient contact?"),
        "video": "/static/images/safe_approach.png",
        "choices": [
            {"label": _("YES, begin survey"), "next": "abcde_start", "color": "success"},
        ]
    },
}
