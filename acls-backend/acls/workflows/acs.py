from django.utils.translation import gettext_lazy as _

ACS_WORKFLOW = {
    "acs_start": {
        "title": _("Chest Pain / Heart Blood Flow Problem"),
        "question": _("ACS refers to a range of conditions associated with sudden, reduced blood flow to the heart. Identify the suspected type base on ECG/Vitals:\n- STEMI: Total vessel occlusion.\n- NSTEMI / UA: Partial vessel occlusion.\n\nContinue to clinical assessment?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (CHECK SYMPTOMS)"), "next": "acs_signs_symptoms", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "acs_signs_symptoms": {
        "title": _("Chest Problem Signs"),
        "question": _("Assess for the 5 cardinal signs of ACS:\n1. PAIN: Discomfort or pressure in the chest.\n2. RADIATION: Pain in jaw, neck, back, arm, or shoulder.\n3. RESPIRATORY: Shortness of breath.\n4. SYSTEMIC: Lightheadedness, nausea, or vomiting.\n5. SKIN: Sweating (Diaphoresis).\n\nSigns present?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (START STABILIZATION)"), "next": "acs_primary_survey", "color": "danger"},
            {"label": _("NO"), "next": "dashboard", "color": "success"}
        ]
    },
    "acs_primary_survey": {
        "title": _("First Check for ACS"),
        "question": _("Ensure safety (Gloves, Mask). Perform Stabilization:\n- AIRWAY: Ensure patency, provide suction if needed.\n- BREATHING: SpO2 monitoring. Give O2 if < 94% or patient is in distress.\n- CIRCULATION: Attach Cardiac Monitor, Pulse/BP/Capillary Refill check, Establish IV/IO access.\n- DISABILITY: Check consciousness (AVPU / GCS).\n- EXPOSURE: Expose chest for assessment, apply leads, maintain privacy.\n\nProceed to detailed history?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (SECONDARY SURVEY)"), "next": "acs_secondary_survey", "color": "primary"}
        ]
    },
    "acs_secondary_survey": {
        "title": _("Chest Problem: History and Exam"),
        "question": _("Perform Clinical Assessment:\n- HISTORY: SAMPLEX (Signs, Allergies, Meds, Past Hx, Last meal, Events).\n- PAIN QUALITY: OPQRST (Onset, Provoke, Quality, Radiation, Severity, Time).\n- URGENT: Obtain 12-lead ECG and Troponin bloods (if possible).\n\nReady for MONA Treatment Protocol?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (START TREATMENT)"), "next": "acs_mona_protocol", "color": "primary"}
        ]
    },
    "acs_mona_protocol": {
        "title": _("Chest Problem Treatment"),
        "question": _("Initiate Professional Treatment immediately:\n- (M) MORPHINE: IV morphine + antiemetic for pain relief.\n- (O) OXYGEN: Administer to maintain target SATS > 94%.\n- (N) GTN: Glyceryl Trinitrate per protocol.\n- (A) ASPIRIN: Administer 300 MG (if no contraindications).\n\nProceed to transport notes?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (FINAL NOTES)"), "next": "acs_final_notes", "color": "primary"}
        ]
    },
    "acs_final_notes": {
        "title": _("Chest Problem: Final Notes"),
        "question": _("Clinical Pearls for EMTs:\n- Do NOT delay transport for prolonged on-scene treatment.\n- Early pain relief and rapid reperfusion are critical.\n- Always recheck contraindications before giving medications.\n\nComplete mission?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("FINISH MISSION"), "next": "dashboard", "color": "success"},
            {"label": _("BACK"), "next": "acs_start", "color": "secondary"}
        ]
    },
}
