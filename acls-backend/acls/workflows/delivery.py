from django.utils.translation import gettext_lazy as _

DELIVERY_WORKFLOW = {
    "delivery_start": {
        "title": _("Labour & Normal Delivery"),
        "question": _("Assess the patient. Identify the stage of Labour:\n- STAGE 1: Dilation (Cervix opening)\n- STAGE 2: Expulsion (Baby delivery)\n- STAGE 3: Placental (Placenta delivery)"),
        "video": "/static/images/birth_stages_dilation.png",
        "choices": [
            {"label": _("STAGE 1: DILATION"), "next": "delivery_stage_1", "color": "primary"},
            {"label": _("STAGE 2: EXPULSION"), "next": "delivery_mechanics_1", "color": "primary"},
            {"label": _("STAGE 3: PLACENTAL"), "next": "delivery_stage_3", "color": "primary"},
            {"label": _("BACK"), "next": "dashboard", "color": "secondary"}
        ]
    },
    "delivery_stage_1": {
        "title": _("Stage 1: Dilation Stage"),
        "question": _("The cervix is partially dilated. Placenta is attached. Goal: Monitor contractions and fetal heart rate. Proceed to next stage when fully dilated?"),
        "video": "/static/images/birth_stages_dilation.png",
        "choices": [
            {"label": _("GO TO STAGE 2"), "next": "delivery_mechanics_1", "color": "success"},
            {"label": _("BACK"), "next": "delivery_start", "color": "secondary"}
        ]
    },
    "delivery_mechanics_1": {
        "title": _("Birth Mechanics 1: Head Floating"),
        "question": _("Step 1: Head floating before engagement. Monitor for descent. Ready for engagement and flexion?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (ENGAGEMENT)"), "next": "delivery_mechanics_2", "color": "primary"},
            {"label": _("BACK"), "next": "delivery_start", "color": "secondary"}
        ]
    },
    "delivery_mechanics_2": {
        "title": _("Birth Mechanics 2: Descent"),
        "question": _("Step 2-4: Engagement, Flexion, and Internal Rotation. The baby is descending. Ready for crowning and extension?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (EXTENSION)"), "next": "delivery_mechanics_3", "color": "primary"}
        ]
    },
    "delivery_mechanics_3": {
        "title": _("Birth Mechanics 3: Shoulder Delivery"),
        "question": _("Step 5-8: Complete Rotation and Extension. Head is out. Restitution (External Rotation). Deliver Anterior then Posterior shoulder. Baby born?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES! BABY BORN"), "next": "nls_start", "color": "success"}
        ]
    },
    "delivery_stage_3": {
        "title": _("Stage 3: Placental Stage"),
        "question": _("The baby is born. The placenta is detaching from the uterus. Deliver the placenta and perform fundal massage to prevent bleeding. Done?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("FINISH"), "next": "dashboard", "color": "success"}
        ]
    },
    "nls_start": {
        "title": _("NEONATAL LIFE SUPPORT (NLS)"),
        "question": _("Perform Initial Newborn Assessment: Term gestation? Breathing or crying? Good muscle tone?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (STAY WITH MOTHER)"), "next": "dashboard", "color": "success"},
            {"label": _("NO (START STABILIZATION)"), "next": "nls_golden_minute", "color": "danger"}
        ]
    },
    "nls_golden_minute": {
        "title": _("The Golden Minute"),
        "question": _("The Golden Minute (0-60s): Maintain normal temperature, position airway, stimulate. Reassess Heart Rate:"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("HR > 100 (BUT CYANOSIS)"), "next": "nls_cyanosis", "color": "warning"},
            {"label": _("HR < 100 (GASPING)"), "next": "nls_ppv", "color": "danger"}
        ]
    },
    "nls_cyanosis": {
        "title": _("NLS: Laboured Breathing"),
        "question": _("Initial stabilization done. Consider CPAP for laboured breathing or persistent cyanosis. SpO2 monitoring is required. Clinical improvement?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES"), "next": "dashboard", "color": "success"}
        ]
    },
    "nls_ppv": {
        "title": _("NLS: Positive Pressure Ventilation"),
        "question": _("Provide PPV and monitor SpO2. Re-check HR after 30 seconds:"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("HR IS NORMAL"), "next": "dashboard", "color": "success"},
            {"label": _("HR STILL < 100"), "next": "nls_airway_check", "color": "danger"}
        ]
    },
    "nls_airway_check": {
        "title": _("NLS: Airway/Leak Check"),
        "question": _("Ensure open airway, reduce leaks, increase pressure and oxygen. Consider Intubation or LMA. Check HR:"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("HR < 60"), "next": "nls_compressions", "color": "danger"}
        ]
    },
    "nls_compressions": {
        "title": _("NLS: Chest Compressions"),
        "question": _("Start 3 chest compressions to 1 breath (3:1 ratio). Give 100% oxygen. Establish venous access. Still HR < 60?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("YES (DRUGS)"), "next": "nls_drugs", "color": "danger"}
        ]
    },
    "nls_drugs": {
        "title": _("NLS: Drugs & Volume"),
        "question": _("Administer IV Adrenaline (1:10,000) and consider volume expansion (Normal Saline). Continue resuscitation. Mission complete?"),
        "video": "/static/images/abcde_start.png",
        "choices": [
            {"label": _("FINISH"), "next": "dashboard", "color": "success"}
        ]
    }
}
