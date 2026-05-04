from django.utils.translation import gettext_lazy as _

STROKE_WORKFLOW = {
    "stroke_start": {
        "title": _("Step 1: Check Face & Arms"),
        "question": _("Perform the F.A.S.T Check:\n1. FACE: Ask them to smile. Does one side drop?\n2. ARMS: Ask them to lift both arms. Does one fall?\n3. SPEECH: Is their speech slurred?\n4. TIME: Note the time.\n\nProceed?"),
        "video": "/static/images/stroke_assessment.png",
        "choices": [
            {"label": _("YES, they look like a stroke"), "next": "stroke_time", "color": "danger"},
            {"label": _("NO, they look okay"), "next": "dashboard", "color": "success", "isExit": True}
        ]
    },
    "stroke_time": {
        "title": _("Step 2: Ask about Time"),
        "question": _("Ask the family: When did this start? Was the person okay an hour ago? Record the time."),
        "video": "/static/images/stroke_types.png",
        "choices": [
            {"label": _("Time recorded"), "next": "stroke_transport", "color": "primary"},
        ]
    },
    "stroke_transport": {
        "title": _("Step 3: Go to Hospital Fast"),
        "question": _("Do NOT give them any water or food. Take them to a big hospital very fast!"),
        "video": "/static/images/call_108.png",
        "choices": [
            {"label": _("FINISH STROKE"), "next": "stroke_complete", "color": "success"},
        ]
    },
    "stroke_complete": {
        "title": _("Stroke Complete"),
        "question": _("Acute stroke assessment complete. Would you like to review the full Systematic Approach (ABCDE) next?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("CONTINUE TO ABCDE"), "next": "abcde_start", "color": "primary"},
            {"label": _("FINISH MODULE"), "next": "dashboard", "color": "success"}
        ]
    },
}
