from django.utils.translation import gettext_lazy as _

CHOKING_WORKFLOW = {
    "choking_start": {
        "title": _("Choking"),
        "question": _("Choose adult or baby."),
        "interactive_component": "choice_cards",
        "interactive_props": {
            "footer_note": _("Pick the right age group for the steps."),
            "options": [
                {
                    "label": _("ADULT"),
                    "description": _("12 years or older"),
                    "image": "/static/images/adult_avatar_v2.png",
                    "next": "adult_choking_step1",
                    "theme": "orange",
                    "badge": "check",
                    "action_label": _("ADULT")
                },
                {
                    "label": _("BABY"),
                    "description": _("Under 12 months"),
                    "image": "/static/images/infant_avatar_v2.png",
                    "next": "infant_choking_step1",
                    "theme": "red",
                    "badge": "alert",
                    "action_label": _("BABY")
                }
            ]
        },
        "choices": []
    },
    "adult_choking_step1": {
        "title": _("Step 1: Wake the person"),
        "question": _("Tap the shoulders and shout. Is the person awake?"),
        "video": "/static/images/choking_step1.png",
        "choices": [
            {"label": _("YES"), "next": "adult_choking_step2", "color": "primary"},
            {"label": _("NO"), "next": "bls_start", "color": "danger"}
        ]
    },
    "adult_choking_step2": {
        "title": _("Step 2: Can they breathe?"),
        "question": _("Is the person able to speak or breathe?"),
        "video": "/static/images/choking_step2.png",
        "choices": [
            {"label": _("YES"), "next": "adult_choking_step3", "color": "primary"},
            {"label": _("NO"), "next": "adult_choking_step4", "color": "danger"}
        ]
    },
    "adult_choking_step3": {
        "title": _("Step 3: Let them cough"),
        "question": _("The person is coughing forcefully. Encourage them to keep coughing. Do not interfere with their efforts."),
        "video": "/static/images/choking_step3.png",
        "choices": [
            {"label": _("KEEP WATCHING"), "next": "adult_choking_step2", "color": "primary"}
        ]
    },
    "adult_choking_step4": {
        "title": _("Step 4: Bad choking signs"),
        "question": _("Look for signs of severe airway obstruction:\n- Silent cough\n- Inability to speak or breathe\n- Lips turning blue (Cyanosis)"),
        "video": "/static/images/choking_step4.png",
        "choices": [
            {"label": _("YES"), "next": "adult_choking_step5", "color": "danger"},
            {"label": _("NO"), "next": "adult_choking_step3", "color": "primary"}
        ]
    },
    "adult_choking_step5": {
        "title": _("Step 5: Push the belly"),
        "question": _("Give 5 abdominal thrusts (Heimlich Maneuver). Push in and up above the navel."),
        "video": "/static/videos/abdominalthrusts.mp4",
        "choices": [
            {"label": _("DONE"), "next": "adult_choking_step6", "color": "primary"}
        ]
    },
    "adult_choking_step6": {
        "title": _("Step 6: Is the object out?"),
        "question": _("Is the obstructing object removed from the airway?"),
        "video": "/static/images/choking_step6.png",
        "choices": [
            {"label": _("YES"), "next": "adult_choking_complete", "color": "success"},
            {"label": _("NO"), "next": "adult_choking_step7", "color": "danger"}
        ]
    },
    "adult_choking_complete": {
        "title": _("Adult Choking Complete"),
        "question": _("You have successfully handled adult choking. Would you like to review infant choking management steps next?"),
        "video": "/static/images/infant_avatar_v2.png",
        "choices": [
            {"label": _("CONTINUE TO BABY"), "next": "infant_choking_step1", "color": "success"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "adult_choking_step7": {
        "title": _("Step 7: Is the person fainting?"),
        "question": _("Is the person becoming unresponsive or fainting?"),
        "video": "/static/images/choking_step7.png",
        "choices": [
            {"label": _("YES"), "next": "bls_start", "color": "danger"},
            {"label": _("NO"), "next": "adult_choking_step5", "color": "primary"}
        ]
    },
    "infant_choking_step1": {
        "title": _("Step 1: Wake the baby"),
        "question": _("Tap the infant's foot and shout. Is the baby responsive?"),
        "video": "/static/images/infant_choking_step1.png",
        "choices": [
            {"label": _("YES"), "next": "infant_choking_step2", "color": "primary"},
            {"label": _("NO"), "next": "bls_start", "color": "danger"}
        ]
    },
    "infant_choking_step2": {
        "title": _("Step 2: Is the baby breathing?"),
        "question": _("Is the infant crying, speaking, or breathing?"),
        "video": "/static/images/infant_choking_signs.png",
        "choices": [
            {"label": _("YES"), "next": "infant_choking_step3", "color": "primary"},
            {"label": _("NO"), "next": "infant_choking_step4", "color": "danger"}
        ]
    },
    "infant_choking_step3": {
        "title": _("Step 3: Let the baby cough"),
        "question": _("The infant is crying or coughing. Encourage them to continue and monitor closely."),
        "video": "/static/images/infant_choking_signs.png",
        "choices": [
            {"label": _("KEEP WATCHING"), "next": "infant_choking_step2", "color": "primary"}
        ]
    },
    "infant_choking_step4": {
        "title": _("Step 4: Bad choking signs"),
        "question": _("Look for signs of severe airway obstruction:\n- No sound or weak cry\n- Inability to breathe\n- Lips turning blue"),
        "video": "/static/images/infant_choking_signs.png",
        "choices": [
            {"label": _("YES"), "next": "infant_choking_step5", "color": "danger"},
            {"label": _("NO"), "next": "infant_choking_step3", "color": "primary"}
        ]
    },
    "infant_choking_step5": {
        "title": _("Step 5: Back slaps"),
        "question": _("Give up to 5 back slaps. Support the infant face-down on your forearm with the head lower than the chest."),
        "video": "/static/images/infant_choking_relief.png",
        "choices": [
            {"label": _("DONE"), "next": "infant_choking_step6", "color": "primary"}
        ]
    },
    "infant_choking_step6": {
        "title": _("Step 6: Chest pushes"),
        "question": _("Give up to 5 chest thrusts. Support the infant face-up on your forearm with the head lower than the chest."),
        "video": "/static/images/infant_choking_relief.png",
        "choices": [
            {"label": _("DONE"), "next": "infant_choking_step7", "color": "primary"}
        ]
    },
    "infant_choking_step7": {
        "title": _("Step 7: Is the object out?"),
        "question": _("Is the obstructing object removed from the infant's airway?"),
        "video": "/static/images/infant_choking_relief.png",
        "choices": [
            {"label": _("YES"), "next": "infant_choking_complete", "color": "success"},
            {"label": _("NO"), "next": "infant_choking_step8", "color": "danger"}
        ]
    },
    "infant_choking_complete": {
        "title": _("Infant Choking Complete"),
        "question": _("You have successfully handled infant choking. Would you like to review adult choking management steps next?"),
        "video": "/static/images/adult_avatar_v2.png",
        "choices": [
            {"label": _("CONTINUE TO ADULT"), "next": "adult_choking_step1", "color": "success"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "infant_choking_step8": {
        "title": _("Step 8: Is the baby fainting?"),
        "question": _("Is the infant becoming unresponsive or limp?"),
        "video": "/static/images/infant_choking_relief.png",
        "choices": [
            {"label": _("YES"), "next": "bls_start", "color": "danger"},
            {"label": _("NO"), "next": "infant_choking_step5", "color": "primary"}
        ]
    }
}