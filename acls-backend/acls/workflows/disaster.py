from django.utils.translation import gettext_lazy as _

DISASTER_WORKFLOW = {
    "triage_start": {
        "title": _("START Triage: Initial Sort"),
        "question": _("Call out for all walking wounded to move to a safe holding area. Are any victims able to walk?"),
        "video": "/static/images/triage.png",
        "choices": [
            {"label": _("YES (MINOR/GREEN)"), "next": "triage_tag_green", "color": "success"},
            {"label": _("NO (START ASSESSMENT)"), "next": "triage_respirations", "color": "primary"}
        ]
    },
    "triage_respirations": {
        "title": _("START Triage: Respirations"),
        "question": _("Is the victim breathing spontaneously?"),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("YES"), "next": "triage_rate", "color": "primary"},
            {"label": _("NO"), "next": "triage_position_airway", "color": "danger"}
        ]
    },
    "triage_position_airway": {
        "title": _("START Triage: Airway Maneuver"),
        "question": _("Position the airway. Is the victim breathing now?"),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("YES (IMMEDIATE/RED)"), "next": "triage_tag_red", "color": "danger"},
            {"label": _("NO (DECEASED/BLACK)"), "next": "triage_tag_black", "color": "dark"}
        ]
    },
    "triage_rate": {
        "title": _("START Triage: Respiratory Rate"),
        "question": _("Assess Respiratory Rate. Is it over 30/min or under 10/min?"),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("YES (IMMEDIATE/RED)"), "next": "triage_tag_red", "color": "danger"},
            {"label": _("NO (UNDER 30/MIN)"), "next": "triage_perfusion", "color": "primary"}
        ]
    },
    "triage_perfusion": {
        "title": _("START Triage: Perfusion"),
        "question": _("Assess Perfusion: Is the radial pulse absent OR Capillary refill > 2 seconds?"),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("YES (PASS)"), "next": "triage_mental_status", "color": "primary"},
            {"label": _("NO (IMMEDIATE/RED)"), "next": "triage_tag_red", "color": "danger"}
        ]
    },
    "triage_mental_status": {
        "title": _("START Triage: Mental Status"),
        "question": _("Assess Mental Status: Is the victim unable to follow simple commands?"),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("YES (DELAYED/YELLOW)"), "next": "triage_tag_yellow", "color": "warning"},
            {"label": _("NO (IMMEDIATE/RED)"), "next": "triage_tag_red", "color": "danger"}
        ]
    },
    "triage_tag_green": {
        "title": _("START Triage: GREEN Tag"),
        "question": _("Tag the walking wounded as GREEN (Minor). Move them to a safe area, recheck them periodically, and continue sorting the remaining victims."),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("GREEN TAG APPLIED"), "next": "disaster_tagging", "color": "success"}
        ]
    },
    "triage_tag_yellow": {
        "title": _("START Triage: YELLOW Tag"),
        "question": _("Tag this victim as YELLOW (Delayed). They are stable enough to wait briefly, but they still need transport and repeated reassessment."),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("YELLOW TAG APPLIED"), "next": "disaster_tagging", "color": "warning"}
        ]
    },
    "triage_tag_red": {
        "title": _("START Triage: RED Tag"),
        "question": _("Tag this victim as RED (Immediate). Prioritize rapid airway, breathing, and circulation support with the fastest possible evacuation."),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("RED TAG APPLIED"), "next": "disaster_tagging", "color": "danger"}
        ]
    },
    "triage_tag_black": {
        "title": _("START Triage: BLACK Tag"),
        "question": _("Tag this victim as BLACK (Deceased/Expectant) according to protocol. Do not spend scene time here while other salvageable victims still need triage."),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("BLACK TAG APPLIED"), "next": "disaster_tagging", "color": "dark"}
        ]
    },
    "disaster_tagging": {
        "title": _("Disaster Management: Apply Triage Tags"),
        "question": _("Confirm that every sorted casualty has a visible triage tag or mark and has been moved or directed according to category before treatment priorities continue. Tagging complete?"),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("TAGGING COMPLETE"), "next": "disaster_stabilize", "color": "primary"},
            {"label": _("BACK TO TRIAGE"), "next": "triage_start", "color": "secondary"}
        ]
    },
    "disaster_start": {
        "title": _("Disaster Management: PPE & Scene Safety"),
        "question": _("Put on disaster PPE before entry: helmet, gloves, mask, reflective jacket, and eye protection if needed. Is the scene safe enough for you to enter?"),
        "video": "/static/videos/safetychecks.mp4",
        "choices": [
            {"label": _("YES, ENTER SAFELY"), "next": "disaster_hazard_sizeup", "color": "success"},
            {"label": _("NO, WAIT FOR CLEARANCE"), "next": "disaster_wait_clearance", "color": "danger"}
        ]
    },
    "disaster_wait_clearance": {
        "title": _("Disaster Management: Hold for Clearance"),
        "question": _("Do not enter the hazard zone. Stay in a safe area, update the 108 control room, and wait until fire, police, rescue, or site command confirms safe access. Has clearance been given?"),
        "video": "/static/images/scene_safety.png",
        "choices": [
            {"label": _("YES, CLEARANCE RECEIVED"), "next": "disaster_hazard_sizeup", "color": "success"},
            {"label": _("NO, KEEP STAGING"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "disaster_hazard_sizeup": {
        "title": _("Disaster Management: Casualties & Hazards"),
        "question": _("Identify casualty numbers, hazard zones, access and exit routes, and immediate threats such as fire, gas, electricity, traffic, or structural collapse. Size-up complete?"),
        "video": "/static/images/scene_assessment.png",
        "choices": [
            {"label": _("SIZE-UP COMPLETE"), "next": "disaster_command", "color": "primary"},
            {"label": _("BACK"), "next": "disaster_start", "color": "secondary"}
        ]
    },
    "disaster_command": {
        "title": _("Disaster Management: Incident Command"),
        "question": _("Report to the incident command point or control room. Confirm casualty count, hazard zones, access routes, and whether fire, police, or rescue support is needed."),
        "video": "/static/images/mci_command.png",
        "choices": [
            {"label": _("COMMAND UPDATED"), "next": "disaster_resources", "color": "success"},
            {"label": _("BACK"), "next": "disaster_start", "color": "secondary"}
        ]
    },
    "disaster_resources": {
        "title": _("Disaster Management: Resource Request"),
        "question": _("Request the right resources early: extra ambulances, rescue teams, police, fire, lighting, and transport support. Declare MCI status if indicated."),
        "video": "/static/images/ems_backup.png",
        "choices": [
            {"label": _("RESOURCES REQUESTED"), "next": "disaster_triage_entry", "color": "primary"},
            {"label": _("BACK"), "next": "disaster_command", "color": "secondary"}
        ]
    },
    "disaster_triage_entry": {
        "title": _("Disaster Management: START Triage"),
        "question": _("Begin START triage. Sort every victim before committing your team to prolonged treatment on one patient. Ready to start the first pass?"),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("START TRIAGE"), "next": "triage_start", "color": "primary"},
            {"label": _("BACK"), "next": "disaster_resources", "color": "secondary"}
        ]
    },
    "disaster_stabilize": {
        "title": _("Disaster Management: Immediate Stabilization"),
        "question": _("After tagging, give only rapid life-saving interventions that fit the disaster setting: open airway, support breathing, control major bleeding, and move RED patients toward evacuation."),
        "video": "/static/images/triage_priority.png",
        "choices": [
            {"label": _("LIFE THREATS ADDRESSED"), "next": "disaster_communicate", "color": "primary"},
            {"label": _("BACK TO TRIAGE"), "next": "triage_start", "color": "secondary"}
        ]
    },
    "disaster_communicate": {
        "title": _("Disaster Management: Control Room Update"),
        "question": _("Communicate the latest scene picture to the 108 control room and receiving hospitals: total victims, triage categories, hazards, airway concerns, and transport priority."),
        "video": "/static/images/ems_dispatch.png",
        "choices": [
            {"label": _("UPDATE SENT"), "next": "disaster_transport", "color": "primary"},
            {"label": _("BACK"), "next": "disaster_stabilize", "color": "secondary"}
        ]
    },
    "disaster_transport": {
        "title": _("Disaster Management: Transport Priority"),
        "question": _("Transport RED patients first, then YELLOW. Keep GREEN patients together in a safe holding area and handle BLACK category according to local disaster protocol."),
        "video": "/static/images/ems_dispatch.png",
        "choices": [
            {"label": _("TRANSPORT ORDER SET"), "next": "disaster_handover", "color": "success"},
            {"label": _("BACK"), "next": "disaster_communicate", "color": "secondary"}
        ]
    },
    "disaster_handover": {
        "title": _("Disaster Management: Handover & Records"),
        "question": _("At hospital handover, give a short structured report with triage tag, major injuries, vitals, treatment given, and transport timeline. Keep written records for every patient moved."),
        "video": "/static/images/ems_dispatch.png",
        "choices": [
            {"label": _("HANDOVER COMPLETE"), "next": "disaster_debrief", "color": "success"},
            {"label": _("BACK"), "next": "disaster_transport", "color": "secondary"}
        ]
    },
    "disaster_debrief": {
        "title": _("Disaster Management: Debrief"),
        "question": _("After the mission, attend debrief, report safety issues, restock equipment, and check crew wellbeing before returning to service."),
        "video": "/static/images/safe_approach.png",
        "choices": [
            {"label": _("FINISH DISASTER MODULE"), "next": "dashboard", "color": "success"},
            {"label": _("BACK"), "next": "disaster_handover", "color": "secondary"}
        ]
    }
}
