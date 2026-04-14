import logging
import json
import os

logger = logging.getLogger(__name__)

TELUGU_MAPPINGS = {
    # Buttons & Common
    "YES": "అవును",
    "NO": "కాదు",
    "BACK": "వెనుకకు",
    "HOME": "హోమ్",
    "DONE": "పూర్తయింది",
    "START": "ప్రారంభించండి",
    "CONTINUE": "కొనసాగించు",
    "CHECKED (NEXT)": "తనిఖీ చేయబడింది (తదుపరి)",
    "COMPLETE": "పూర్తి",
    "FINISH": "ముగించు",
    "READY": "సిద్ధం",
    "BACK TO DASHBOARD": "డాష్‌బోర్డ్‌కి తిరిగి వెళ్ళండి",
    "START ASSESSMENT (ABCDE)": "అసెస్మెంట్ ప్రారంభించండి (ABCDE)",
    
    # Titles & Modules
    "Start ACLS": "ACLS ప్రారంభించండి",
    "Scene Safety & PPE": "సీన్ భద్రత & PPE",
    "Systematic ABCDE": "క్రమబద్ధమైన ABCDE",
    "BLS & CPR": "BLS & CPR శిక్షణ",
    "Choking Management": "ఉక్కిరిబిక్కిరి కావడం మేనేజ్‌మెంట్",
    "Airway Anatomy": "ఎయిర్‌వే అనాటమీ",
    "Advanced Airway": "అడ్వాన్స్‌డ్ ఎయిర్‌వే",
    "Trauma & Bleeding": "ట్రామా & రక్తస్రావం",
    "Poisoning Management": "విషప్రయోగం నిర్వహణ (Poisoning)",
    "Snake Bite Management": "పాముకాటు నిర్వహణ",
    "Stroke Assessment": "స్ట్రోక్ అస్సెస్మెంట్",
    "Disaster Management": "డిజాస్టర్ మేనేజ్‌మెంట్",
    "NLS & Delivery": "NLS & డెలివరీ",
    "ECG Waves & Basics": "ECG వేవ్స్ & బేసిక్స్",
    "Rhythms & Blocks": "రిథమ్స్ & బ్లాక్స్",
    "Cardiac Algorithms": "కార్డియాక్ అల్గోరిథమ్స్",
    "Reversible Causes (H5T5)": "రివర్సిబుల్ కాసెస్ (H's & T's)",
    "Professional ACLS Simulator": "ప్రొఫెషనల్ ACLS సిమ్యులేటర్",
    "Training": "శిక్షణ",
    "Testing": "పరీక్ష",
    "Certification": "సర్టిఫికేషన్",
    "Start CPR": "CPR ప్రారంభించండి",
    "Monitor/Defibrillator": "మానిటర్/డిఫిబ్రిలేటర్",
    "Secondary Survey": "ద్వితీయ సర్వే",
    "SAMPLE History": "SAMPLE చరిత్ర",
    "Final Actions": "తుది చర్యలు",

    # Questions & Content
    "Is the scene safe?": "సీన్ సురక్షితమా?",
    "Is the patient responsive?": "రోగి ప్రతిస్పందిస్తున్నారా?",
    "Did anyone see the person collapse?": "వ్యక్తి పడిపోవడం మీరు చూశారా?",
    "Is the patient breathing normally?": "రోగి సాధారణంగా శ్వాస తీసుకుంటున్నారా?",
    "Is a pulse present (within 10 seconds)?": "పల్స్ ఉందా (10 సెకండ్లలోపు)?",
    "Start high-quality CPR now?": "ఇప్పుడు అధిక-నాణ్యత గల CPR ప్రారంభించాలా?",
    "Is a defibrillator / cardiac monitor available?": "డిఫిబ్రిలేటర్ / కార్డియాక్ మానిటర్ అందుబాటులో ఉందా?",
    "EMS Priority 1: Scene Safety. Is the immediate area safe for you and your team to enter?": "EMS ప్రాధాన్యత 1: సీన్ భద్రత. మీరు మరియు మీ బృందం ప్రవేశించడానికి తక్షణ ప్రాంతం సురక్షితమేనా?",
    "Start with ABCDE: Airway, Breathing, Circulation, Disability, Exposure. Proceed?": "ABCDE తో ప్రారంభించండి: ఎయిర్‌వే, బ్రీతింగ్, సర్క్యులేషన్, డిసేబిలిటీ, ఎక్స్‌పోజర్. కొనసాగించాలా?",
    "Assess Airway, Breathing, and Circulation for immediate life threats. Proceed?": "తక్షణ ప్రాణాపాయాల కోసం ఎయిర్‌వే, బ్రీతింగ్ మరియు సర్క్యులేషన్‌ను అంచనా వేయండి. కొనసాగించాలా?",
    "YES, Area is safe": "అవును, ప్రాంతం సురక్షితం",
    "NO, Hazards present": "కాదు, ప్రమాదాలు ఉన్నాయి",
    "AIRWAY (A)": "వాయుమార్గం (A)",
    "BREATHING (B)": "శ్వాస (B)",
    "CIRCULATION (C)": "రక్త ప్రసరణ (C)",
    "DISABILITY (D)": "వైకల్యం (D)",
    "EXPOSURE (E)": "ఎక్స్‌పోజర్ (E)",
    
    # Categories from api_views
    "Level 1: Basic Life Saving": "స్థాయి 1: ప్రాథమిక జీవన రక్షణ",
    "Level 2: Emergency Management": "స్థాయి 2: అత్యవసర నిర్వహణ",
    "Level 3: Advanced Cardiac (ACLS)": "స్థాయి 3: అడ్వాన్స్‌డ్ కార్డియాక్ (ACLS)",
    "START HERE": "ఇక్కడ ప్రారంభించండి",
    "INTERMEDIATE": "మధ్యస్థం",
    "ADVANCED": "అడ్వాన్స్‌డ్",
    "Training": "శిక్షణ",
    "Testing": "పరీక్ష",
    "Certification": "సర్టిఫికేషన్",
    "Learn the first steps to save a life. Perfect for beginners.": "ప్రాణాలను రక్షించే మొదటి దశలను నేర్చుకోండి. ప్రారంభకులకు ఉత్తమం.",
}

# Try to load translations from PO file extraction
json_path = os.path.join(os.path.dirname(__file__), 'po_translations.json')
if os.path.exists(json_path):
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            po_data = json.load(f)
            TELUGU_MAPPINGS.update(po_data)
    except Exception as e:
        logger.error(f"Failed to load po_translations.json: {e}")

def translate_to_te(text):
    """
    Translates English text to Telugu using internal mapping.
    Returns original text if no translation found.
    """
    if not text:
        return text
    
    # Try exact match
    translated = TELUGU_MAPPINGS.get(text)
    if translated:
        # logger.debug(f"DEBUG: Found translation for '{text}' -> '{translated}'")
        return translated
    
    # Try normalized match (strip whitespace)
    translated = TELUGU_MAPPINGS.get(text.strip())
    if translated:
        return translated
        
    logger.warning(f"DEBUG: No translation found for '{text}'")
    return text

def translate_dict(data, lang='en'):
    """
    Recursively translates values in a dictionary if language is Telugu.
    """
    if not lang or not lang.startswith('te'):
        return data
        
    if isinstance(data, dict):
        new_data = {}
        for k, v in data.items():
            # Fields that usually contain human-readable text
            if k in ['title', 'question', 'label', 'description', 'notice', 'action_label', 'name', 'tag', 'footer_note']:
                if isinstance(v, (str, bytes)) or hasattr(v, '__html__') or not isinstance(v, (dict, list)):
                    # Convert to string to handle lazy translation objects
                    new_data[k] = translate_to_te(str(v))
                else:
                    new_data[k] = translate_dict(v, lang)
            else:
                new_data[k] = translate_dict(v, lang)
        return new_data
    elif isinstance(data, list):
        return [translate_dict(item, lang) for item in data]
    else:
        return data

