from django.utils.translation import gettext_lazy as _

RHYTHMS_WORKFLOW = {
    "rhythms_start": {
        "title": _("Rhythms & Blocks"),
        "question": _("Identify the rhythm group you want to study:"),
        "video": "/static/images/ecg_rhythms.png",
        "choices": [
            {"label": _("SINUS RHYTHMS"), "next": "rhythms_sinus", "color": "primary"},
            {"label": _("TACHYARRHYTHMIAS"), "next": "rhythms_tachy", "color": "danger"},
            {"label": _("ARREST RHYTHMS"), "next": "rhythms_arrest", "color": "dark"},
            {"label": _("HEART BLOCKS"), "next": "rhythms_blocks", "color": "warning"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
    "rhythms_sinus": {
        "title": _("Sinus Rhythms"),
        "question": _("Recognize:\n- NSR: Normal (60-100)\n- Sinus Brady: <50 bpm\n- Sinus Tachy: >100 bpm"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["nsr", "sinus_brady", "sinus_tachy"]},
        "choices": [
            {"label": _("CONTINUE"), "next": "rhythms_start", "color": "primary"}
        ]
    },
    "rhythms_tachy": {
        "title": _("Tachyarrhythmias"),
        "question": _("Recognize:\n- SVT: Fast, narrow QRS\n- AFib: Irregular, no P waves\n- V-Tach: Wide complex tachycardia"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["svt", "afib", "vtach"]},
        "choices": [
            {"label": _("CONTINUE"), "next": "rhythms_start", "color": "primary"}
        ]
    },
    "rhythms_arrest": {
        "title": _("Cardiac Arrest Rhythms"),
        "question": _("EMTs must immediately identify:\n- VT: Wide QRS, regular\n- VF: Chaotic waveform\n- Asystole: Flat line"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vtach", "vfib", "asystole"]},
        "choices": [
            {"label": _("CONTINUE"), "next": "rhythms_start", "color": "primary"}
        ]
    },
    "rhythms_blocks": {
        "title": _("Heart Blocks"),
        "question": _("1. 1st Degree: Long PR (>0.20s)\n2. 2nd Deg Type I: PR lengthening -> Drop\n3. 2nd Deg Type II: Fixed PR -> Drop\n4. 3rd Degree: P and QRS independent"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["block_1st", "block_2nd_type1", "block_2nd_type2", "block_3rd"]},
        "choices": [
            {"label": _("CONTINUE"), "next": "rhythms_start", "color": "primary"}
        ]
    },
}
