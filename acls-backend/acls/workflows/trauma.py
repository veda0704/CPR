from django.utils.translation import gettext_lazy as _

TRAUMA_WORKFLOW = {
    "trauma_start": {
        "title": _("Trauma Survey"),
        "question": _("Patient involved in a traumatic event. Ensure scene safety and BSI. Ready to start Primary Survey?"),
        "video": "/static/images/trauma_primary.png",
        "choices": [
            {"label": _("START SURVEY"), "next": "trauma_exsanguination", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "trauma_exsanguination": {
        "title": _("Step X: Exsanguination"),
        "question": _("Is there massive life-threatening bleeding? Apply a tourniquet or direct pressure immediately! Controlled?"),
        "video": "/static/images/bleeding.png",
        "choices": [
            {"label": _("YES, CONTROLLED"), "next": "trauma_airway", "color": "success"},
            {"label": _("NOT CONTROLLED"), "next": "trauma_bleeding_help", "color": "danger"}
        ]
    },
    "trauma_bleeding_help": {
        "title": _("Bleeding Intervention"),
        "question": _("Apply a tourniquet higher up or use a second pressure bandage. If bleeding is in a junction (neck/groin), use hemostatic gauze. Controlled now?"),
        "video": "/static/images/bleeding.png",
        "choices": [
            {"label": _("YES, CONTROLLED"), "next": "trauma_airway", "color": "success"},
            {"label": _("STILL BLEEDING"), "next": "trauma_bleeding_help", "color": "danger"}
        ]
    },
    "trauma_airway": {
        "title": _("Step A: Airway & C-Spine"),
        "question": _("Assess airway and stabilize Cervical Spine. Use Jaw Thrust if needed. Airway patent and spine stabilized?"),
        "video": "/static/images/trauma_primary.png",
        "choices": [
            {"label": _("YES, SECURED"), "next": "trauma_breathing", "color": "primary"},
            {"label": _("NEED AIRWAY HELP"), "next": "abcde_airway_intervention", "color": "warning"}
        ]
    },
    "trauma_breathing": {
        "title": _("Step B: Breathing"),
        "question": _("Assess for tension pneumothorax, open chest wounds, or flail chest. Provide oxygen. Breathing adequate?"),
        "video": "/static/images/breathing.png",
        "choices": [
            {"label": _("YES, ADEQUATE"), "next": "trauma_circulation", "color": "success"},
            {"label": _("NO, ASSIST VENTILATION"), "next": "trauma_breathing_help", "color": "danger"}
        ]
    },
    "trauma_breathing_help": {
        "title": _("Ventilation Support"),
        "question": _("Use Bag-Valve-Mask (BVM) to assist breathing. Ensure chest rise. If tension pneumothorax suspected, prepare for needle decompression. Ready?"),
        "video": "/static/images/breathing.png",
        "choices": [
            {"label": _("VENTILATION STARTED"), "next": "trauma_circulation", "color": "success"},
        ]
    },
    "trauma_circulation": {
        "title": _("Step C: Circulation"),
        "question": _("Check pulse and skin. Look for hidden bleeding (Pelvis, Long bones). Apply pelvic binder if needed. Stable?"),
        "video": "/static/images/pulse_check.png",
        "choices": [
            {"label": _("YES, STABLE"), "next": "trauma_disability", "color": "success"},
            {"label": _("NO, TREAT SHOCK"), "next": "trauma_shock_help", "color": "danger"}
        ]
    },
    "trauma_shock_help": {
        "title": _("Shock Management"),
        "question": _("Establish two large-bore IVs. Consider warm crystalloids or blood products. Apply pelvic binder or splints if needed. Ready?"),
        "video": "/static/images/pulse_check.png",
        "choices": [
            {"label": _("STABILIZING"), "next": "trauma_disability", "color": "success"},
        ]
    },
    "trauma_disability": {
        "title": _("Step D: Disability"),
        "question": _("Check GCS/AVPU and pupils. Note any focal deficits. Neuro status recorded?"),
        "video": "/static/images/trauma_secondary.png",
        "choices": [
            {"label": _("DONE"), "next": "trauma_exposure", "color": "primary"}
        ]
    },
    "trauma_exposure": {
        "title": _("Step E: Exposure"),
        "question": _("Expose injuries but prevent hypothermia. Keep the patient warm! Ready for Secondary Survey?"),
        "video": "/static/images/trauma_secondary.png",
        "choices": [
            {"label": _("CONTINUE TO SECONDARY"), "next": "abcde_secondary", "color": "success"},
            {"label": _("FINISH MODULE"), "next": "trauma_complete", "color": "primary"}
        ]
    },
    "trauma_complete": {
        "title": _("Trauma Complete"),
        "question": _("Primary trauma management complete. Follow hospital protocols for definitive care."),
        "video": "/static/images/trauma_secondary.png",
        "choices": [
            {"label": _("BACK TO DASHBOARD"), "next": "dashboard", "color": "success"}
        ]
    },
}
