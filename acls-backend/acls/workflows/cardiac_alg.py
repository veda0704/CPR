from django.utils.translation import gettext_lazy as _

CARDIAC_ALG_WORKFLOW = {
    "cardiac_alg_start": {
        "title": _("ACLS Cardiac Algorithms"),
        "question": _("Choose the treatment path based on the person's condition:"),
        "video": "/static/images/algorithm.png",
        "choices": [
            {"label": _("TACHYCARDIA (With Pulse)"), "next": "alg_tachy_assess", "color": "danger"},
            {"label": _("BRADYCARDIA (With Pulse)"), "next": "alg_brady_assess", "color": "warning"},
            {"label": _("CARDIAC ARREST (No Pulse)"), "next": "8", "color": "dark"},
            {"label": _("POST-ARREST CARE (ROSC)"), "next": "alg_post_arrest_start", "color": "success"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "alg_tachy_assess": {
        "title": _("Tachycardia Assessment"),
        "question": _("Assess the rhythm and signs. Decide if the tachycardia is stable or unstable."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["svt"]},
        "choices": [
            {"label": _("DONE (CHECK STABILITY)"), "next": "alg_tachy_stability", "color": "primary"}
        ]
    },
    "alg_tachy_stability": {
        "title": _("Fast Heart Rate: Stable?"),
        "question": _("Persistent tachyarrhythmia causing:\n- Hypotension?\n- Altered Mental Status?\n- Signs of Shock?\n- Chest Pain?\n- Acute Heart Failure?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["afib"]},
        "choices": [
            {"label": _("UNSTABLE (Signs Exist)"), "next": "alg_tachy_unstable", "color": "danger"},
            {"label": _("STABLE (No Signs)"), "next": "alg_tachy_stable", "color": "success"}
        ]
    },
    "alg_tachy_unstable": {
        "title": _("Fast Heart Rate: Unstable"),
        "question": _("Use synchronized shock (cardioversion) if the person is unstable. Follow energy settings for each rhythm type.") ,
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vtach"]},
        "choices": [
            {"label": _("CARDIOVERTED (SUCCESS)"), "next": "alg_post_arrest_start", "color": "success"},
            {"label": _("FAIL -> ADVANCED EXPERT"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "alg_tachy_stable": {
        "title": _("Tachycardia: Stable"),
        "question": _("Is the QRS Wide (>= 0.12 seconds) or Narrow?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["svt"]},
        "choices": [
            {"label": _("WIDE QRS"), "next": "alg_tachy_wide", "color": "warning"},
            {"label": _("NARROW QRS"), "next": "alg_tachy_narrow", "color": "success"}
        ]
    },
    "alg_tachy_wide": {
        "title": _("Stable Wide QRS"),
        "question": _("Consider Adenosine only if regular and monomorphic.\nConsider antiarrhythmic infusion (Amiodarone 150mg over 10m OR Procainamide 20-50mg/min).\nSeek Expert Consultation."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vtach"]},
        "choices": [
            {"label": _("DONE"), "next": "alg_tachy_complete", "color": "success"}
        ]
    },
    "alg_tachy_complete": {
        "title": _("Tachycardia Complete"),
        "question": _("Tachycardia management review complete. Would you like to review Bradycardia (Slow Heart Rate) steps next?"),
        "video": "/static/images/algorithm_brady.png",
        "choices": [
            {"label": _("CONTINUE TO BRADYCARDIA"), "next": "alg_brady_assess", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
    "alg_tachy_narrow": {
        "title": _("Stable Narrow QRS"),
        "question": _("Vagal maneuvers.\nAdenosine 6mg rapid IV push (if regular).\nBeta-blocker or Calcium channel blocker.\nSeek Expert Consultation."),
        "video": "/static/videos/vagal_maneuver.mp4",
        "choices": [
            {"label": _("DONE"), "next": "alg_tachy_complete", "color": "success"}
        ]
    },
    "alg_brady_assess": {
        "title": _("Slow Heart Rate: Assessment"),
        "question": _("If the heart is slow, keep the airway open, give oxygen, check blood pressure, and get IV access. Obtain ECG if available."),
        "video": "/static/videos/bradycardia.mp4",
        "choices": [
            {"label": _("YES (CHECK SYMPTOMS)"), "next": "alg_brady_symptoms", "color": "primary"}
        ]
    },
    "alg_brady_symptoms": {
        "title": _("Bradycardia: Symptomatic?"),
        "question": _("Persistent bradycardia causing:\n- Hypotension?\n- Signs of Shock?\n- Acute Mental Status Change?\n- Chest Discomfort?\n- Acute Heart Failure?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["block_3rd"]},
        "choices": [
            {"label": _("YES (SYMPTOMATIC)"), "next": "alg_brady_treatment", "color": "danger"},
            {"label": _("NO (ASYMPTOMATIC)"), "next": "alg_brady_monitor", "color": "success"}
        ]
    },
    "alg_brady_monitor": {
        "title": _("Bradycardia: Monitor"),
        "question": _("Monitor clinical condition and observe. No medication needed at this time."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["sinus_brady"]},
        "choices": [
            {"label": _("COMPLETE"), "next": "alg_brady_complete", "color": "success"}
        ]
    },
    "alg_brady_treatment": {
        "title": _("Bradycardia: Atropine"),
        "question": _("Administer Atropine 1mg IV. Repeat every 3-5min if needed (Max 3mg). Was it effective?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["block_2nd_type2"]},
        "choices": [
            {"label": _("YES (EFFECTIVE)"), "next": "alg_brady_monitor", "color": "success"},
            {"label": _("NO (INEFFECTIVE)"), "next": "alg_brady_advanced", "color": "danger"}
        ]
    },
    "alg_brady_advanced": {
        "title": _("Bradycardia: Advanced"),
        "question": _("Initiate Transcutaneous Pacing OR\nDopamine IV infusion (5-20 mcg/kg/min) OR\nEpinephrine IV infusion (2-10 mcg/min).\nConsider Transvenous pacing / Expert Consult."),
        "video": "/static/videos/pacing.mp4",
        "choices": [
            {"label": _("DONE"), "next": "alg_brady_complete", "color": "success"}
        ]
    },
    "alg_brady_complete": {
        "title": _("Bradycardia Complete"),
        "question": _("Bradycardia management review complete. Would you like to review Cardiac Arrest algorithms next?"),
        "video": "/static/images/algorithm_vf_vt.png",
        "choices": [
            {"label": _("CONTINUE TO CARDIAC ARREST"), "next": "vf_workflow", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
    "vf_workflow": {
        "title": _("VF Identified"),
        "question": _("Ventricular Fibrillation (VF) confirmed. Patient is pulseless. Initiate protocol."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vfib"]},
        "choices": [
            {"label": _("SHOCK (DEFIBRILLATE)"), "next": "vf_shock_1", "color": "danger"}
        ]
    },
    "vt_no_pulse_workflow": {
        "title": _("pVT Identified"),
        "question": _("Pulseless Ventricular Tachycardia (pVT) confirmed. Initiate protocol."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vtach"]},
        "choices": [
            {"label": _("SHOCK (DEFIBRILLATE)"), "next": "vf_shock_1", "color": "danger"}
        ]
    },
    "vf_shock_1": {
        "title": _("1st Shock Delivered"),
        "question": _("Immediate high-quality CPR for 2 minutes.\nEstablish IV/IO access.\n\nDone?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vfib"]},
        "choices": [
            {"label": _("RHYTHM CHECK (2 MIN)"), "next": "vf_check_2", "color": "primary"}
        ]
    },
    "vf_check_2": {
        "title": _("Rhythm Check"),
        "question": _("Stop CPR.\nIs the rhythm still shockable?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vfib"]},
        "choices": [
            {"label": _("YES (STILL VF/VT)"), "next": "vf_shock_2", "color": "danger"},
            {"label": _("NO (ASYSTOLE/PEA)"), "next": "pea_workflow", "color": "warning"},
            {"label": _("NO (ROSC)"), "next": "alg_post_arrest_start", "color": "success"}
        ]
    },
    "vf_shock_2": {
        "title": _("2nd Shock Delivered"),
        "question": _("Resume CPR for 2 minutes.\nAdminister Epinephrine 1mg every 3-5 mins.\nConsider Advanced Airway/Capnography.\n\nDone?"),
        "video": "/static/videos/Adrenaline.mp4",
        "choices": [
            {"label": _("RHYTHM CHECK (2 MIN)"), "next": "vf_check_3", "color": "primary"}
        ]
    },
    "vf_check_3": {
        "title": _("Rhythm Check"),
        "question": _("Stop CPR.\nIs the rhythm still shockable?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["vfib"]},
        "choices": [
            {"label": _("YES (SHOCK AGAIN)"), "next": "vf_shock_3", "color": "danger"},
            {"label": _("NO (CHECK PULSE)"), "next": "pea_workflow", "color": "warning"}
        ]
    },
    "vf_shock_3": {
        "title": _("3rd Shock Delivered"),
        "question": _("Resume CPR for 2 minutes.\nAdminister Amiodarone (300mg bolus) OR Lidocaine (1-1.5 mg/kg).\nTreat reversible causes (5H & 5T).\n\nDone?"),
        "video": "/static/videos/Amiodarone.mp4",
        "choices": [
            {"label": _("CONTINUE ALGORITHM"), "next": "vf_check_2", "color": "primary"}
        ]
    },
    "asystole_workflow": {
        "title": _("Asystole Identified"),
        "question": _("Flatline rhythm. Not shockable. Initiate protocol."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["asystole"]},
        "choices": [
            {"label": _("START CPR + MEDS"), "next": "pea_cpr_1", "color": "primary"}
        ]
    },
    "pea_workflow": {
        "title": _("PEA Identified"),
        "question": _("Organized rhythm on monitor but NO pulse. Not shockable. Initiate protocol."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["nsr"]},
        "choices": [
            {"label": _("START CPR + MEDS"), "next": "pea_cpr_1", "color": "primary"}
        ]
    },
    "pea_cpr_1": {
        "title": _("CPR & Epinephrine"),
        "question": _("CPR for 2 minutes.\nAdminister Epinephrine 1mg ASAP (repeat every 3-5m).\nObtain IV/IO.\nConsider Advanced Airway.\n\nDone?"),
        "video": "/static/videos/Adrenaline.mp4",
        "choices": [
            {"label": _("RHYTHM CHECK (2 MIN)"), "next": "pea_check_1", "color": "primary"}
        ]
    },
    "pea_check_1": {
        "title": _("Rhythm Check"),
        "question": _("Stop CPR.\nIs the rhythm shockable?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["asystole"]},
        "choices": [
            {"label": _("NO (STILL ASYSTOLE/PEA)"), "next": "pea_cpr_2", "color": "warning"},
            {"label": _("YES (VF/VT SPONTANEOUS)"), "next": "vf_shock_1", "color": "danger"},
            {"label": _("NO (ROSC)"), "next": "alg_post_arrest_start", "color": "success"}
        ]
    },
    "pea_cpr_2": {
        "title": _("Resume CPR"),
        "question": _("Resume CPR for 2 minutes.\nIdentify and treat reversible causes (Hypovolemia, Hypoxia, Hydrogen ion, Hypo/Hyperkalemia, Hypothermia, Tension Pneumothorax, Tamponade, Toxins, Thrombosis).\n\nDone?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["asystole"]},
        "choices": [
            {"label": _("RHYTHM CHECK (2 MIN)"), "next": "pea_check_1", "color": "primary"}
        ]
    },
    "alg_post_arrest_start": {
        "title": _("ROSC Achieved (Post-Arrest)"),
        "question": _("Return of Spontaneous Circulation (ROSC) achieved!\n\nOptimize Ventilation/Oxygenation:\n- SpO2 92-98%\n- PaCO2 35-45 mmHg\n- Place Advanced Airway if needed.\n\nDone?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["nsr"]},
        "choices": [
            {"label": _("YES (CHECK BP)"), "next": "post_arrest_bp", "color": "primary"}
        ]
    },
    "post_arrest_bp": {
        "title": _("Blood Pressure Support"),
        "question": _("Maintain Systolic BP > 90 mmHg (MAP > 65).\nIf hypotensive: 1-2L Normal Saline bolus OR Vasopressor infusion.\n\nObtain 12-lead ECG (evaluate for STEMI).\n\nDone?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["nsr"]},
        "choices": [
            {"label": _("YES (ASSESS MENTAL STATUS)"), "next": "post_arrest_ttm", "color": "primary"}
        ]
    },
    "post_arrest_ttm": {
        "title": _("Targeted Temperature Management"),
        "question": _("Does the patient follow commands (Awake) or are they Comatose?"),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["nsr"]},
        "choices": [
            {"label": _("COMATOSE"), "next": "post_arrest_comatose", "color": "warning"},
            {"label": _("AWAKE (FOLLOWS COMMANDS)"), "next": "post_arrest_awake", "color": "success"}
        ]
    },
    "post_arrest_comatose": {
        "title": _("Comatose Management"),
        "question": _("Initiate Targeted Temperature Management (TTM).\nObtain Brain CT.\nMonitor EEG.\nAvoid barotrauma/hyperventilation.\nTransfer to ICU."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["nsr"]},
        "choices": [
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
    "post_arrest_awake": {
        "title": _("Awake Management"),
        "question": _("Monitor core temperature.\nMaintain blood oxygen, glucose, and hemodynamics.\nAvoid barotrauma.\nTransfer to ICU."),
        "interactive_component": "ecg_monitor",
        "interactive_props": {"rhythms": ["nsr"]},
        "choices": [
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
    "alg_post_arrest_complete": {
        "title": _("Post-Arrest Complete"),
        "question": _("Post-Cardiac Arrest management review complete. Would you like to review Reversible Causes (5H & 5T) next?"),
        "video": "/static/images/cardiacarrest.png",
        "choices": [
            {"label": _("CONTINUE TO 5H & 5T"), "next": "h5t5_start", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
}
