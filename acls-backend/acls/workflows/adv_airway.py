from django.utils.translation import gettext_lazy as _

ADV_AIRWAY_WORKFLOW = {
    "adv_airway_start": {
        "title": _("Advanced Airway"),
        "question": _("Pick the advanced device to open the airway:"),
        "video": "/static/images/lma_procedure.png",
        "choices": [
            {"label": _("LMA (Supraglottic)"), "next": "lma_prep", "color": "success"},
            {"label": _("ET TUBE (RSI)"), "next": "rsi_steps_main", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "lma_prep": {
        "title": _("LMA - Preparation"),
        "question": _("1. Position: Sniffing position\n2. Size: Based on weight\n3. Cuff: Check & Deflate\n4. Lubricate posterior surface\n5. Preoxygenate\n\nReady?"),
        "video": "/static/images/lma_procedure.png",
        "choices": [
            {"label": _("YES (INSERTION STEPS)"), "next": "lma_steps", "color": "primary"},
            {"label": _("BACK"), "next": "adv_airway_start", "color": "secondary"}
        ]
    },
    "lma_steps": {
        "title": _("LMA - Insertion Steps"),
        "question": _("1. Hold LMA firmly\n2. Open mouth\n3. Insert deflated mask pointing to feet\n4. Guide along palate past tongue\n5. Advance to resistance\n\nDone?"),
        "video": "/static/images/lma_procedure.png",
        "choices": [
            {"label": _("DONE (POST-INSERTION)"), "next": "lma_post", "color": "primary"},
            {"label": _("BACK"), "next": "lma_prep", "color": "secondary"}
        ]
    },
    "lma_post": {
        "title": _("LMA - Post-Insertion"),
        "question": _("1. Inflate cuff\n2. Connect Bag-Valve\n3. Confirm placement (chest rise/breath sounds)\n4. Secure LMA with tape\n\nComplete?"),
        "video": "/static/images/lma_procedure.png",
        "choices": [
            {"label": _("FINISH"), "next": "dashboard", "color": "success"}
        ]
    },
    "rsi_steps_main": {
        "title": _("RSI - 7 Steps"),
        "question": _("1. Preparation\n2. Preoxygenation\n3. Pretreatment\n4. Paralysis with Induction\n5. Protection/Positioning\n6. Placement of Tube (ETT)\n7. Postintubation Management\n\nComplete?"),
        "video": "/static/images/rsi_procedure.png",
        "choices": [
            {"label": _("COMPLETE"), "next": "dashboard", "color": "success"},
            {"label": _("BACK"), "next": "adv_airway_start", "color": "secondary"}
        ]
    },
}
