from django.utils.translation import gettext_lazy as _

H5T5_WORKFLOW = {
    "h5t5_start": {
        "title": _("Check Common Treatable Causes"),
        "question": _("Look for common, treatable causes of cardiac arrest. Start the 10-point check?"),
        "video": "/static/images/cardiacarrest.png",
        "choices": [
            {"label": _("BEGIN CHECK"), "next": "h1_hypovolemia", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "h1_hypovolemia": {
        "title": _("H1: Low Blood Volume"),
        "question": _("Is there heavy bleeding or fluid loss? Check pulse and signs of poor blood flow. Treatment: Give fluids as needed."),
        "video": "/static/images/bleeding.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "h2_hypoxia", "color": "primary"}
        ]
    },
    "h2_hypoxia": {
        "title": _("H2: Low Oxygen"),
        "question": _("Is the patient getting enough oxygen? Look for slow heart rate and bluish skin. Treatment: Open airway and give oxygen."),
        "video": "/static/images/oxygen.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "h3_hydrogen", "color": "primary"}
        ]
    },
    "h3_hydrogen": {
        "title": _("H3: Acid in Blood"),
        "question": _("Could the patient's blood be too acidic? Check for kidney or diabetes problems. Treatment: Improve breathing and ventilation."),
        "video": "/static/images/breathing.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "h4_hyperkalemia", "color": "primary"}
        ]
    },
    "h4_hyperkalemia": {
        "title": _("H4: Potassium Problem"),
        "question": _("Could potassium be too high or too low? Check the heart monitor and treat per protocol with calcium or fluids."),
        "video": "/static/images/ecg_rhythms.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "h5_hypothermia", "color": "primary"}
        ]
    },
    "h5_hypothermia": {
        "title": _("H5: Cold Body"),
        "question": _("Is the patient's body too cold? Check skin and temperature. Treatment: Warm them gently."),
        "video": "/static/images/pulse_check.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "t1_tension", "color": "primary"}
        ]
    },
    "t1_tension": {
        "title": _("T1: Chest Air Trap"),
        "question": _("Is air trapped in the chest and squeezing the lung? Look for shifting and no breath sounds. Treatment: release the trapped air."),
        "video": "/static/images/breathing.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "t2_tamponade", "color": "primary"}
        ]
    },
    "t2_tamponade": {
        "title": _("T2: Fluid Around Heart"),
        "question": _("Is fluid pressing on the heart? Look for fast pulse and weak blood pressure. Treatment: remove the fluid around the heart."),
        "video": "/static/images/circulation.jpg",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "t3_toxins", "color": "primary"}
        ]
    },
    "t3_toxins": {
        "title": _("T3: Poison or Overdose"),
        "question": _("Could this be poison or overdose? Look for small pupils, slow breathing, or other signs. Treatment: give antidotes if indicated."),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "t4_thrombosis_p", "color": "primary"}
        ]
    },
    "t4_thrombosis_p": {
        "title": _("T4: Lung Blood Clot"),
        "question": _("Could there be a blood clot in the lungs? Look for fast heart rate and breathing trouble. Treatment: follow protocol for clot dissolving or surgery."),
        "video": "/static/images/thrombosis_lungs.png",
        "choices": [
            {"label": _("CHECKED (NEXT)"), "next": "t5_thrombosis_c", "color": "primary"}
        ]
    },
    "t5_thrombosis_c": {
        "title": _("T5: Heart Blood Clot"),
        "question": _("Could a blood clot be blocking the heart? Look for signs on ECG. Treatment: urgent hospital intervention."),
        "video": "/static/images/thrombosis_heart.png",
        "choices": [
            {"label": _("FINISH H5T5"), "next": "h5t5_complete", "color": "success"}
        ]
    },
    "h5t5_complete": {
        "title": _("H5T5 Complete"),
        "question": _("Reversible causes (5H & 5T) check complete. Would you like to return to the Cardiac Arrest algorithms next?"),
        "video": "/static/images/algorithm_vf_vt.png",
        "choices": [
            {"label": _("CONTINUE TO CARDIAC ARREST"), "next": "cardiac_alg_start", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    }
}
