from django.utils.translation import gettext_lazy as _

ECG_WORKFLOW = {
    "ecg_start": {
        "title": _("ECG & Rhythm Management"),
        "question": _("Master the art of ECG interpretation. Choose your learning path:"),
        "interactive_component": "choice_cards",
        "interactive_props": {
            "options": [
                {
                    "label": _("ECG BASICS"),
                    "description": _("Learn waves, intervals, and paper scales."),
                    "image": "/static/images/ecg_intro.png",
                    "next": "ecg_waves",
                    "theme": "teal",
                    "action_label": _("LEARN BASICS")
                },
                {
                    "label": _("RHYTHM STUDY"),
                    "description": _("Master Sinus, Tachy, Arrest, and Blocks."),
                    "image": "/static/images/ecg_rhythms.png",
                    "next": "rhythms_start",
                    "theme": "orange",
                    "action_label": _("STUDY RHYTHMS")
                }
            ]
        },
        "choices": [
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "ecg_waves": {
        "title": _("Understanding ECG Waves"),
        "question": _("1. P wave: Atria contract\n2. PR interval (0.12-0.20 sec): Signal travel\n3. QRS complex (<0.12 sec): Ventricles contract\n4. ST segment & T wave: Ventricles relax\n\nDone?"),
        "video": "/static/images/ecg_waves.png",
        "choices": [
            {"label": _("NEXT: PAPER BASICS"), "next": "ecg_paper", "color": "primary"},
            {"label": _("BACK"), "next": "ecg_start", "color": "secondary"}
        ]
    },
    "ecg_paper": {
        "title": _("ECG Paper Basics"),
        "question": _("1 Large Box = 0.2 Seconds\n5 Large Boxes = 1.0 Second\n1 Small Box = 0.04 Seconds\nVoltage: 10mm = 1mV\n\nReady to check rhythms?"),
        "video": "/static/images/ecg_paper.png",
        "choices": [
            {"label": _("YES (RHYTHM CHECK)"), "next": "ecg_check", "color": "primary"},
            {"label": _("BACK"), "next": "ecg_waves", "color": "secondary"}
        ]
    },
    "ecg_check": {
        "title": _("Stepwise Rhythm Check"),
        "question": _("1. Rate: Count QRS (60-100 normal)\n2. Rhythm: Regular or irregular?\n3. P Waves: Present before Every QRS?\n4. PR Interval: Normal or prolonged?\n5. QRS Width: Narrow or wide?\n6. ST Segment: Elevated or depressed?\n\nProceed?"),
        "video": "/static/images/ecg_paper.png",
        "choices": [
            {"label": _("YES (COMMON RHYTHMS)"), "next": "ecg_common_rhythms", "color": "primary"},
            {"label": _("BACK"), "next": "ecg_paper", "color": "secondary"}
        ]
    },
    "ecg_common_rhythms": {
        "title": _("Common Rhythms"),
        "question": _("EMTs must recognize:\n- NSR: Normal (60-100 bpm)\n- Bradycardia (<50 bpm)\n- Tachycardia (>100 bpm)\n- AF: Irregular, no P waves\n- VT/VF: Life-threatening\n- STEMI: ST elevation\n\nReady for action points?"),
        "video": "/static/images/ecg_rhythms.png",
        "choices": [
            {"label": _("YES (ACTION POINTS)"), "next": "ecg_action_points", "color": "primary"},
            {"label": _("BACK"), "next": "ecg_check", "color": "secondary"}
        ]
    },
    "ecg_action_points": {
        "title": _("Action Points & Golden Rules"),
        "question": _("1. Assess patient first (ABC)\n2. Shockable (VT/VF): Start CPR + ACLS immediately\n3. Stable: Monitor & Take help\n4. ACS/STEMI: Aspirin 300mg, O2 (if <94%), Transmit ECG & Rapid Transport\n\nGolden Rules:\n- Treat the patient, not the ECG\n- Don't get lost in interpretation\n- Correlate with symptoms"),
        "video": "/static/images/ecg_rules.png",
        "choices": [
            {"label": _("CONTINUE TO RHYTHM STUDY"), "next": "rhythms_start", "color": "success"},
            {"label": _("BACK"), "next": "ecg_common_rhythms", "color": "secondary"}
        ]
    },
}
