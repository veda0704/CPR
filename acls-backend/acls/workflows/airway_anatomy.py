from django.utils.translation import gettext_lazy as _

AIRWAY_ANATOMY_WORKFLOW = {
    "airway_start": {
        "title": _("Airway Management"),
        "question": _("Check the throat and breathing. Start with simple maneuvers first?"),
        "video": "/static/images/airway_anatomy.png",
        "choices": [
            {"label": _("ANATOMY & MANEUVERS"), "next": "airway_maneuvers", "color": "primary"},
            {"label": _("AIRWAY ADJUNCTS"), "next": "airway_adjuncts", "color": "success"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary", "isExit": True}
        ]
    },
    "airway_maneuvers": {
        "title": _("Airway Maneuvers"),
        "question": _("Perform Head Tilt - Chin Lift or Jaw Thrust (if spinal injury suspected). Opening the airway is critical. Done?"),
        "video": "/static/images/AirwayManeuvers.png",
        "choices": [
            {"label": _("DONE (NEXT: ADJUNCTS)"), "next": "airway_adjuncts", "color": "primary"},
            {"label": _("BACK"), "next": "airway_start", "color": "secondary"}
        ]
    },
    "airway_adjuncts": {
        "title": _("Airway Adjuncts"),
        "question": _("Select and place OPA or NPA. Give oxygen with a mask or bag if available. Done?"),
        "video": "/static/images/AirwayAdjuncts.png",
        "choices": [
            {"label": _("DONE"), "next": "dashboard", "color": "success"}
        ]
    },
}
