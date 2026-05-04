from django.utils.translation import gettext_lazy as _

BLS_WORKFLOW = {
    "bls_start": {
        "title": _("Step 1: Scene Safety & Response"),
        "question": _("Ensure the scene is safe. Tap the patient and shout: 'Are you okay?'. Are they responsive?"),
        "video": "/static/videos/responsive_2.mp4",
        "choices": [
            {"label": _("YES, RESPONSIVE"), "next": "dashboard", "color": "success"},
            {"label": _("NO, UNRESPONSIVE"), "next": "bls_help", "color": "danger"}
        ]
    },
    "bls_help": {
        "title": _("Step 2: Call for Help"),
        "question": _("Shout for help! Tell someone to call emergency services and get an AED. Proceed to check patient?"),
        "video": "/static/images/call_for_help.png",
        "choices": [
            {"label": _("PROCEED"), "next": "bls_pulse", "color": "primary"}
        ]
    },
    "bls_pulse": {
        "title": _("Step 3: Pulse & Breathing"),
        "question": _("Simultaneously check for breathing (look for chest rise) and carotid pulse for 5-10 seconds. Is pulse present?"),
        "video": "/static/videos/Pulse.mp4",
        "choices": [
            {"label": _("YES, HAS PULSE"), "next": "bls_rescue_breathing", "color": "success"},
            {"label": _("NO PULSE, NOT BREATHING"), "next": "bls_cpr_start", "color": "danger"}
        ]
    },
    "bls_rescue_breathing": {
        "title": _("Rescue Breathing"),
        "question": _("Give 1 breath every 6 seconds (10 breaths/min). Check pulse every 2 minutes. Proceed to dashboard?"),
        "video": "/static/images/rescue_breathing.png",
        "choices": [
            {"label": _("DONE"), "next": "bls_complete", "color": "success"}
        ]
    },
    "bls_cpr_start": {
        "title": _("Step 4: High-Quality CPR"),
        "question": _("Start 30 compressions and 2 breaths. Push 2 inches (5cm) deep at 100-120 bpm. Allow full chest recoil. CPR in progress?"),
        "video": "/static/videos/CPR.mp4",
        "choices": [
            {"label": _("AED ARRIVED"), "next": "bls_aed_attach", "color": "primary"}
        ]
    },
    "bls_aed_attach": {
        "title": _("Step 5: AED Deployment"),
        "question": _("Turn on the AED. Attach pads to the patient's bare chest. Plug in connector if necessary. Pads attached?"),
        "video": "/static/images/aed_pads.png",
        "choices": [
            {"label": _("YES, ANALYZING"), "next": "bls_aed_analyze", "color": "primary"}
        ]
    },
    "bls_aed_analyze": {
        "title": _("Step 6: Analyze Rhythm"),
        "question": _("AED is analyzing the heart rhythm. 'CLEAR THE PATIENT!'. Is shock advised?"),
        "video": "/static/images/aed_analyze.png",
        "choices": [
            {"label": _("SHOCK ADVISED"), "next": "bls_aed_shock", "color": "danger"},
            {"label": _("NO SHOCK ADVISED"), "next": "bls_cpr_continue", "color": "primary"}
        ]
    },
    "bls_aed_shock": {
        "title": _("Step 7: Delivery Shock"),
        "question": _("'EVERYONE CLEAR!'. Deliver the shock now. After shock, immediately resume CPR."),
        "video": "/static/images/aed_shock.png",
        "choices": [
            {"label": _("SHOCK DELIVERED, RESUME CPR"), "next": "bls_cpr_continue", "color": "primary"}
        ]
    },
    "bls_cpr_continue": {
        "title": _("Step 8: Continue CPR"),
        "question": _("Resume high-quality CPR immediately for 2 minutes (about 5 cycles of 30:2). Switch compressors if needed. Keep going?"),
        "video": "/static/videos/CPR.mp4",
        "choices": [
            {"label": _("FINISH BLS"), "next": "bls_complete", "color": "success"}
        ]
    },
    "bls_complete": {
        "title": _("BLS Complete"),
        "question": _("Basic Life Support review complete. Would you like to review Choking Management (Foreign Body Airway Obstruction) next?"),
        "video": "/static/images/chokingm4.png",
        "choices": [
            {"label": _("CONTINUE TO CHOKING"), "next": "choking_start", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    }
}
