from django.utils.translation import gettext_lazy as _

ABCDE_WORKFLOW = {
    "abcde_start": {
        "title": _("Systematic Approach"),
        "question": _("Start with the Systematic Approach (ABCDE):\n- Airway\n- Breathing\n- Circulation\n- Disability\n- Exposure\n\nProceed?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("AIRWAY (A)"), "next": "abcde_airway", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "abcde_airway": {
        "title": _("Airway Assessment"),
        "question": _("Assess Airway, Breathing, and Circulation for immediate life threats. Proceed?"),
        "interactive_component": "choice_cards",
        "interactive_props": {
            "footer_note": _("Not sure? When in doubt, treat as obstructed and act immediately."),
            "options": [
                {
                    "label": _("AIRWAY OPEN"),
                    "description": _("The throat is clear and air can move in and out."),
                    "notice": _("An open airway lets breathing happen normally."),
                    "image": "/static/images/airway_patent_v3.png",
                    "next": "abcde_airway_open_info",
                    "theme": "orange",
                    "badge": "check",
                    "action_label": _("SELECT OPEN AIRWAY")
                },
                {
                    "label": _("AIRWAY BLOCKED"),
                    "description": _("Something is blocking the throat. Act now."),
                    "notice": _("A blocked airway stops air from going into the lungs."),
                    "image": "/static/images/airway_obstructed_v3.png",
                    "next": "abcde_airway_intervention",
                    "theme": "red",
                    "badge": "alert",
                    "action_label": _("SELECT BLOCKED")
                }
            ]
        },
        "choices": []
    },
    "abcde_airway_open_info": {
        "title": _("Airway Open"),
        "question": _("The airway is patent. Before proceeding to Breathing, would you like to review how to manage a blocked airway?"),
        "video": "/static/images/airway_patent_v3.png",
        "choices": [
            {"label": _("EXPLORE BLOCKED AIRWAY"), "next": "abcde_airway_intervention", "color": "danger"},
            {"label": _("CONTINUE TO BREATHING"), "next": "abcde_breathing", "color": "success"},
            {"label": _("BACK"), "next": "abcde_airway", "color": "secondary"}
        ]
    },
    "abcde_airway_intervention": {
        "title": _("Airway Intervention"),
        "question": _("Open the airway using head tilt-chin lift or jaw thrust (if trauma suspected). Suction if needed and insert adjuncts as available. Airway secured?"),
        "video": "/static/images/airway_maneuvers.png",
        "choices": [
            {"label": _("YES, AIRWAY SECURED"), "next": "abcde_breathing", "color": "success"},
            {"label": _("NEED ADVANCED AIRWAY"), "next": "airway_start", "color": "danger"},
            {"label": _("BACK"), "next": "abcde_airway", "color": "secondary"}
        ]
    },
    "abcde_breathing": {
        "title": _("Breathing (B)"),
        "question": _("Assess rate, depth, and oxygen saturation. Is breathing adequate?"),
        "video": "/static/images/breathing.png",
        "choices": [
            {"label": _("YES"), "next": "abcde_circulation", "color": "success"},
            {"label": _("NO"), "next": "abcde_breathing_support", "color": "danger"}
        ]
    },
    "abcde_breathing_support": {
        "title": _("Breathing Support"),
        "question": _("Provide oxygen, assist ventilation with bag-mask if needed, and treat life-threatening breathing problems. Ready to continue the survey?"),
        "video": "/static/images/abcde_breathing.png",
        "choices": [
            {"label": _("YES, CONTINUE TO CIRCULATION"), "next": "abcde_circulation", "color": "success"},
            {"label": _("NO, START BLS"), "next": "bls_start", "color": "danger"},
            {"label": _("BACK"), "next": "abcde_breathing", "color": "secondary"}
        ]
    },
    "abcde_circulation": {
        "title": _("Blood Flow (C)"),
        "question": _("Check pulse, BP, and skin temperature. Is circulation stable?"),
        "video": "/static/images/circulation.jpg",
        "choices": [
            {"label": _("YES, CONTINUE TO DISABILITY"), "next": "abcde_disability", "color": "success"},
            {"label": _("NO, TREAT SHOCK/BLEEDING"), "next": "abcde_circulation_support", "color": "danger"},
            {"label": _("BACK"), "next": "abcde_breathing", "color": "secondary"}
        ]
    },
    "abcde_circulation_support": {
        "title": _("Blood Flow Support"),
        "question": _("Control major bleeding, support perfusion, and prepare for rapid transport if unstable. Is the patient stable enough to continue?"),
        "video": "/static/images/pulse_check.png",
        "choices": [
            {"label": _("YES, CONTINUE TO DISABILITY"), "next": "abcde_disability", "color": "success"},
            {"label": _("NO, START BLS"), "next": "bls_start", "color": "danger"},
            {"label": _("BACK"), "next": "abcde_circulation", "color": "secondary"}
        ]
    },
    "abcde_disability": {
        "title": _("Brain Check (D)"),
        "question": _("Perform a quick neurologic check (AVPU/GCS, pupils, glucose). Any abnormal finding?"),
        "video": "/static/images/stroke_assessment.png",
        "choices": [
            {"label": _("NO, CONTINUE TO EXPOSURE"), "next": "abcde_exposure", "color": "success"},
            {"label": _("YES, STABILIZE AND CONTINUE"), "next": "abcde_disability_support", "color": "warning"},
            {"label": _("BACK"), "next": "abcde_circulation", "color": "secondary"}
        ]
    },
    "abcde_disability_support": {
        "title": _("Brain Support"),
        "question": _("Treat reversible causes (e.g., hypoglycemia, seizures) and protect airway as needed. Ready to proceed to exposure?"),
        "video": "/static/images/stroke_assessment.png",
        "choices": [
            {"label": _("YES, CONTINUE TO EXPOSURE"), "next": "abcde_exposure", "color": "success"},
            {"label": _("BACK"), "next": "abcde_disability", "color": "secondary"}
        ]
    },
    "abcde_exposure": {
        "title": _("Look for Injuries (E)"),
        "question": _("Expose the patient enough to find hidden injuries while preventing hypothermia. Exposure complete?"),
        "video": "/static/images/scene_assessment.png",
        "choices": [
            {"label": _("YES, SECONDARY SURVEY"), "next": "abcde_secondary", "color": "success"},
            {"label": _("BACK"), "next": "abcde_disability", "color": "secondary"}
        ]
    },
    "abcde_secondary": {
        "title": _("Detailed Check"),
        "question": _("After ABCDE is complete, continue with S-A-M-P-L-E history:\n- Signs & Symptoms\n- Allergies\n- Medications\n- Past Medical History\n- Last Meal\n- Events Leading Up\n\nAnd perform a focused head-to-toe examination."),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("FINISH SYSTEMATIC APPROACH"), "next": "dashboard", "color": "success"},
            {"label": _("BACK"), "next": "abcde_exposure", "color": "secondary"}
        ]
    },
}
