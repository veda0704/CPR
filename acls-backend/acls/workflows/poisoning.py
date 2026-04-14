from django.utils.translation import gettext_lazy as _


POISONING_WORKFLOW = {
    "poisoning_start": {
        "title": _("Poisoning Management"),
        "question": _("Enter the poisoning workflow. Is the scene safe and are you wearing PPE?"),
        "video": "/static/images/poisoning_safety_gear.svg",
        "choices": [
            {"label": _("YES, Proceed"), "next": "poisoning_check", "color": "success"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "poisoning_check": {
        "title": _("Primary Survey (ABCDE)"),
        "question": _("Assess Airway, Breathing, and Circulation. Are they stable?"),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("YES, Stable"), "next": "poisoning_signs", "color": "primary"},
            {"label": _("NO, Resuscitate"), "next": "bls_start", "color": "danger"}
        ]
    },
    "poisoning_signs": {
        "title": _("Toxidrome Assessment"),
        "question": _("Observe the patient for specific signs. What is the suspected toxidrome?"),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("OPIOID (Small pupils, Slow breathing)"), "next": "poisoning_opioid", "color": "primary"},
            {"label": _("ORGANOPHOSPHATE (Sweating, Secretions)"), "next": "poisoning_op", "color": "primary"},
            {"label": _("ANTICHOLINERGIC (Dry skin, Confusion)"), "next": "poisoning_antichol", "color": "primary"},
            {"label": _("OTHER / UNKNOWN"), "next": "poisoning_hos", "color": "primary"}
        ]
    },
    "poisoning_opioid": {
        "title": _("Opioid Overdose"),
        "question": _("Administer Naloxone (0.4mg IV/IM). Monitor for respiratory improvement. Effective?"),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("YES"), "next": "poisoning_hos", "color": "success"},
            {"label": _("NO, Repeat dose"), "next": "poisoning_opioid", "color": "warning"}
        ]
    },
    "poisoning_op": {
        "title": _("Organophosphate Poisoning"),
        "question": _("Administer Atropine (2mg IV). Repeat until secretions clear. Done?"),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("DONE"), "next": "poisoning_hos", "color": "success"},
        ]
    },
    "poisoning_antichol": {
        "title": _("Anticholinergic Toxicity"),
        "question": _("Provide supportive care. Monitor temperature and manage agitation. Ready for transport?"),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("READY"), "next": "poisoning_hos", "color": "primary"},
        ]
    },
    "poisoning_hos": {
        "title": _("Transport & Handover"),
        "question": _("Initiate rapid transport. Provide detailed handover at the destination hospital. Mission complete?"),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("COMPLETE"), "next": "dashboard", "color": "success", "isExit": True},
        ]
    }
}
