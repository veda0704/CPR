from django.utils.translation import gettext_lazy as _

ADV_AIRWAY_WORKFLOW = {
    "adv_airway_start": {
        "title": _("Advanced Airway"),
        "question": _("Pick the advanced device to open the airway:"),
        "video": "/static/images/lma_procedure.png",
        "choices": [
            {"label": _("LMA (Supraglottic)"), "next": "lma_prep", "color": "success"},
            {"label": _("ET TUBE (RSI)"), "next": "rsi_prep", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    # --- LMA PATH ---
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
            {"label": _("FINISH LMA"), "next": "lma_complete_choice", "color": "success"}
        ]
    },
    "lma_complete_choice": {
        "title": _("LMA Complete"),
        "question": _("LMA insertion successful. Would you like to review the Endotracheal Tube (RSI) steps next?"),
        "video": "/static/images/rsi_procedure.png",
        "choices": [
            {"label": _("CONTINUE TO ET TUBE"), "next": "rsi_prep", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },

    # --- RSI PATH (Expanded 7 Steps) ---
    "rsi_prep": {
        "title": _("RSI Step 1: Preparation"),
        "question": _("Check equipment (SOAP ME):\n- Suction working?\n- Oxygen & BVM?\n- Airway tools (Laryngoscope/ETTs)?\n- Pharmacy (Induction/Paralytics)?\n- Monitoring (ECG/SpO2/ETCO2)?\n- Equipment (Stylet/Bougie)?"),
        "video": "/static/images/rsi_procedure.png",
        "choices": [
            {"label": _("PREPARED -> PREOXYGENATE"), "next": "rsi_preox", "color": "success"},
            {"label": _("BACK"), "next": "adv_airway_start", "color": "secondary"}
        ]
    },
    "rsi_preox": {
        "title": _("RSI Step 2: Preoxygenation"),
        "question": _("Administer 100% Oxygen for 3-5 minutes. Ensure SpO2 is maximized before paralysis. Nitrogen washout achieved?"),
        "video": "/static/images/oxygen.png",
        "choices": [
            {"label": _("YES (PRETREATMENT)"), "next": "rsi_pretreat", "color": "primary"},
            {"label": _("BACK"), "next": "rsi_prep", "color": "secondary"}
        ]
    },
    "rsi_pretreat": {
        "title": _("RSI Step 3: Pretreatment"),
        "question": _("Consider Fentanyl or Lidocaine to mitigate the physiologic response to laryngoscopy (if indicated). Ready to induce?"),
        "video": "/static/images/iv_fluids.png",
        "choices": [
            {"label": _("READY TO INDUCE"), "next": "rsi_induction", "color": "primary"},
            {"label": _("BACK"), "next": "rsi_preox", "color": "secondary"}
        ]
    },
    "rsi_induction": {
        "title": _("RSI Step 4: Induction & Paralysis"),
        "question": _("Administer sedative agent (e.g., Etomidate) followed immediately by a rapid-acting paralytic (e.g., Succinylcholine or Rocuronium). Apnea achieved?"),
        "video": "/static/images/iv_fluids.png",
        "choices": [
            {"label": _("APNEA ACHIEVED (POSITION)"), "next": "rsi_position", "color": "danger"},
            {"label": _("BACK"), "next": "rsi_pretreat", "color": "secondary"}
        ]
    },
    "rsi_position": {
        "title": _("RSI Step 5: Positioning"),
        "question": _("Align the oral, pharyngeal, and laryngeal axes into the 'Sniffing Position'. Apply cricoid pressure if indicated. Optimal view possible?"),
        "video": "/static/images/airway_maneuvers.png",
        "choices": [
            {"label": _("YES (LARYNGOSCOPY)"), "next": "rsi_placement", "color": "primary"},
            {"label": _("BACK"), "next": "rsi_induction", "color": "secondary"}
        ]
    },
    "rsi_placement": {
        "title": _("RSI Step 6: Placement of Tube"),
        "question": _("Perform laryngoscopy. Visualize vocal cords. Insert Endotracheal Tube (ETT) and remove stylet. Inflate cuff. Tube in place?"),
        "video": "/static/images/rsi_procedure.png",
        "choices": [
            {"label": _("YES (CONFIRMATION)"), "next": "rsi_post", "color": "success"},
            {"label": _("BACK"), "next": "rsi_position", "color": "secondary"}
        ]
    },
    "rsi_post": {
        "title": _("RSI Step 7: Post-Intubation"),
        "question": _("Confirm placement:\n- Bilateral chest rise?\n- Auscultation (5 points)?\n- Waveform Capnography (ETCO2)?\nSecure the tube and monitor vitals."),
        "video": "/static/images/algorithm_post_arrest.png",
        "choices": [
            {"label": _("COMPLETE RSI"), "next": "rsi_complete_choice", "color": "success"},
            {"label": _("BACK"), "next": "rsi_placement", "color": "secondary"}
        ]
    },
    "rsi_complete_choice": {
        "title": _("RSI Complete"),
        "question": _("ET Tube (RSI) protocol complete. Would you like to review the LMA (Supraglottic) steps next?"),
        "video": "/static/images/lma_procedure.png",
        "choices": [
            {"label": _("CONTINUE TO LMA"), "next": "lma_prep", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
}
