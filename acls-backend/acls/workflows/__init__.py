from .bls import BLS_WORKFLOW
from .abcde import ABCDE_WORKFLOW
from .airway_anatomy import AIRWAY_ANATOMY_WORKFLOW
from .adv_airway import ADV_AIRWAY_WORKFLOW
from .ecg import ECG_WORKFLOW
from .rhythms import RHYTHMS_WORKFLOW
from .cardiac_alg import CARDIAC_ALG_WORKFLOW
from .stroke import STROKE_WORKFLOW
from .acs import ACS_WORKFLOW
from .h5t5 import H5T5_WORKFLOW
from .poisoning import POISONING_WORKFLOW
from .disaster import DISASTER_WORKFLOW
from .snake_bite import SNAKE_BITE_WORKFLOW
from .delivery import DELIVERY_WORKFLOW
from .scene_safety import SCENE_SAFETY_WORKFLOW
from .trauma import TRAUMA_WORKFLOW
from .choking import CHOKING_WORKFLOW
from .acls_sim import ACLS_SIM_WORKFLOW

# Workflow step validation schema
WORKFLOW_STEP_SCHEMA = {
    "required_fields": ["title", "question"],
    "optional_fields": [
        "video", "interactive_component", "interactive_props", 
        "time_limit", "timeout_next", "choices", "audio_url"
    ],
    "field_types": {
        "title": str,
        "question": str,
        "video": (str, type(None)),
        "interactive_component": (str, type(None)),
        "interactive_props": (dict, type(None)),
        "time_limit": (int, type(None)),
        "timeout_next": (str, type(None)),
        "choices": list,
        "audio_url": (str, type(None))
    }
}

def validate_workflow_step(step_id, step_data):
    """
    Validates a workflow step against the schema.
    Returns (is_valid, errors)
    """
    errors = []
    
    # Check required fields
    for field in WORKFLOW_STEP_SCHEMA["required_fields"]:
        if field not in step_data:
            errors.append(f"Missing required field: {field}")
        elif step_data[field] is not None:
            # Allow lazy translation objects (Django's gettext_lazy)
            expected_types = WORKFLOW_STEP_SCHEMA["field_types"].get(field, str)
            if not isinstance(expected_types, tuple):
                expected_types = (expected_types,)
            
            # Check if the value is a lazy translation object or one of the expected types
            from django.utils.functional import Promise
            if not (isinstance(step_data[field], (Promise,) + expected_types)):
                errors.append(f"Invalid type for field {field}: expected {expected_types} or lazy translation, got {type(step_data[field])}")
    
    # Check field types for all present fields
    for field, value in step_data.items():
        if value is not None:
            expected_types = WORKFLOW_STEP_SCHEMA["field_types"].get(field)
            if expected_types:
                if not isinstance(expected_types, tuple):
                    expected_types = (expected_types,)
                
                from django.utils.functional import Promise
                if not (isinstance(value, (Promise,) + expected_types)):
                    errors.append(f"Invalid type for field {field}: expected {expected_types} or lazy translation, got {type(value)}")
    
    return len(errors) == 0, errors

# Merge all workflows into a single dictionary with validation
WORKFLOW_STEPS = {}
all_workflows = [
    ("BLS", BLS_WORKFLOW),
    ("ABCDE", ABCDE_WORKFLOW),
    ("AIRWAY_ANATOMY", AIRWAY_ANATOMY_WORKFLOW),
    ("ADV_AIRWAY", ADV_AIRWAY_WORKFLOW),
    ("ECG", ECG_WORKFLOW),
    ("RHYTHMS", RHYTHMS_WORKFLOW),
    ("CARDIAC_ALG", CARDIAC_ALG_WORKFLOW),
    ("STROKE", STROKE_WORKFLOW),
    ("ACS", ACS_WORKFLOW),
    ("H5T5", H5T5_WORKFLOW),
    ("POISONING", POISONING_WORKFLOW),
    ("DISASTER", DISASTER_WORKFLOW),
    ("SNAKE_BITE", SNAKE_BITE_WORKFLOW),
    ("DELIVERY", DELIVERY_WORKFLOW),
    ("SCENE_SAFETY", SCENE_SAFETY_WORKFLOW),
    ("TRAUMA", TRAUMA_WORKFLOW),
    ("CHOKING", CHOKING_WORKFLOW),
    ("ACLS_SIM", ACLS_SIM_WORKFLOW),
]

for workflow_name, workflow_data in all_workflows:
    for step_id, step_data in workflow_data.items():
        is_valid, validation_errors = validate_workflow_step(step_id, step_data)
        if not is_valid:
            print(f"WARNING: Invalid step {step_id} in {workflow_name}: {validation_errors}")
    WORKFLOW_STEPS.update(workflow_data)
