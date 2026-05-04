from django.utils.translation import gettext_lazy as _

SNAKE_BITE_WORKFLOW = {
    "snake_bite_initial": {
        "title": _("Step 1: Assess ABC's"),
        "question": _("Assess Airway, Breathing, and Circulation for immediate life threats. Proceed?"),
        "video": "/static/images/snake_bite.png",
        "choices": [
            {"label": _("YES"), "next": "snake_bite_toxicity", "color": "primary"}
        ]
    },
    "snake_bite_toxicity": {
        "title": _("Step 2: Toxicity Check"),
        "question": _("Check for signs of Anaphylaxis (severe allergy) or Systemic Toxicity (venom spread). Done?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("DONE"), "next": "snake_bite_limb_jewelry", "color": "primary"}
        ]
    },
    "snake_bite_limb_jewelry": {
        "title": _("Step 3: Limb Assessment"),
        "question": _("Remove jewelry, watches, or rings from the bitten limb to prevent swelling issues. Done?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("DONE"), "next": "snake_bite_iv_access", "color": "primary"}
        ]
    },
    "snake_bite_iv_access": {
        "title": _("Step 4: IV Access"),
        "question": _("Establish IV access in an UNAFFECTED limb. (Do not use the bitten arm/leg). Proceed?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES"), "next": "snake_bite_elevation", "color": "primary"}
        ]
    },
    "snake_bite_elevation": {
        "title": _("Step 5: Elevation"),
        "question": _("Elevate the bitten limb at or ABOVE the level of the heart. Proceed?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES"), "next": "snake_bite_pain", "color": "primary"}
        ]
    },
    "snake_bite_pain": {
        "title": _("Step 6: Pain Control"),
        "question": _("Provide professional pain control (like IV opioids) per protocol. Done?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("DONE"), "next": "snake_bite_fluids", "color": "primary"}
        ]
    },
    "snake_bite_fluids": {
        "title": _("Step 7: IV Fluids"),
        "question": _("Treat low blood pressure with volume resuscitation (IV Fluids). Ready?"),
        "video": "/static/images/iv_fluids.png",
        "choices": [
            {"label": _("YES"), "next": "snake_bite_transport", "color": "primary"}
        ]
    },
    "snake_bite_transport": {
        "title": _("Step 8: Transport"),
        "question": _("Perform rapid transport to a hospital that stocks Antivenom immediately. Proceed?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES! TRANSPORT"), "next": "snake_bite_doctor", "color": "success"}
        ]
    },
    "snake_bite_doctor": {
        "title": _("Step 9: Expert Advice"),
        "question": _("When in doubt, contact a doctor or specialist. Mission complete?"),
        "video": "/static/images/ems_backup.png",
        "choices": [
            {"label": _("FINISH SNAKE BITE"), "next": "snake_bite_complete", "color": "success"}
        ]
    },
    "snake_bite_complete": {
        "title": _("Snake Bite Complete"),
        "question": _("Snake bite management protocol complete. Would you like to review general Poisoning management steps next?"),
        "video": "/static/images/poisoning.png",
        "choices": [
            {"label": _("CONTINUE TO POISONING"), "next": "poisoning_start", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
}
