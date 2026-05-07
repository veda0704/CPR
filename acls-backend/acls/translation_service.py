import logging
import json
import os

logger = logging.getLogger(__name__)

TELUGU_MAPPINGS = {
    # Common Buttons
    "YES": "అవును",
    "NO": "కాదు",
    "BACK": "వెనుకకు",
    "HOME": "హోమ్",
    "DONE": "పూర్తయింది",
    "START": "ప్రారంభించండి",
    "CONTINUE": "కొనసాగించు",
    "FINISH MODULE": "మాడ్యూల్ ముగించు",
    "BACK TO DASHBOARD": "డాష్‌బోర్డ్‌కి తిరిగి వెళ్ళండి",

    # Advanced Airway - Workflow Strings
    "Advanced Airway": "అడ్వాన్స్‌డ్ ఎయిర్‌వే",
    "Pick the advanced device to open the airway:": "వాయుమార్గాన్ని తెరవడానికి అడ్వాన్స్‌డ్ పరికరాన్ని ఎంచుకోండి:",
    "LMA (Supraglottic)": "LMA (సుప్రాగ్లోటిక్)",
    "ET TUBE (RSI)": "ET ట్యూబ్ (RSI)",
    
    "LMA - Preparation": "LMA - తయారీ",
    "1. Position: Sniffing position\n2. Size: Based on weight\n3. Cuff: Check & Deflate\n4. Lubricate posterior surface\n5. Preoxygenate\n\nReady?": "1. పొజిషన్: స్నిఫ్ఫింగ్ పొజిషన్\n2. సైజు: బరువు ఆధారంగా\n3. కఫ్: తనిఖీ & తగ్గించండి\n4. వెనుక ఉపరితలాన్ని లూబ్రికేట్ చేయండి\n5. ప్రీఆక్సిజనేట్ చేయండి\n\nసిద్ధమా?",
    "YES (INSERTION STEPS)": "అవును (చొప్పించే దశలు)",
    
    "LMA - Insertion Steps": "LMA - చొప్పించే దశలు",
    "1. Hold LMA firmly\n2. Open mouth\n3. Insert deflated mask pointing to feet\n4. Guide along palate past tongue\n5. Advance to resistance\n\nDone?": "1. LMAను గట్టిగా పట్టుకోండి\n2. నోరు తెరవండి\n3. పాదాల వైపు చూపిస్తూ డిఫ్లేటెడ్ మాస్క్‌ను చొప్పించండి\n4. అంగిలి వెంబడి నాలుక దాటి గైడ్ చేయండి\n5. ప్రతిఘటన వరకు ముందుకు తీసుకెళ్లండి\n\nపూర్తయిందా?",
    "DONE (POST-INSERTION)": "పూర్తయింది (చొప్పించిన తర్వాత)",
    
    "LMA - Post-Insertion": "LMA - చొప్పించిన తర్వాత",
    "1. Inflate cuff\n2. Connect Bag-Valve\n3. Confirm placement (chest rise/breath sounds)\n4. Secure LMA with tape\n\nComplete?": "1. కఫ్ నింపండి\n2. బ్యాగ్-వాల్వ్‌ను కనెక్ట్ చేయండి\n3. ప్లేస్‌మెంట్‌ను నిర్ధారించండి (ఛాతీ పెరుగుదల/శ్వాస శబ్దాలు)\n4. టేప్‌తో LMAను సురక్షితం చేయండి\n\nపూర్తయిందా?",
    "FINISH LMA": "LMA పూర్తి చేయండి",
    
    "LMA Complete": "LMA పూర్తి",
    "LMA insertion successful. Would you like to review the Endotracheal Tube (RSI) steps next?": "LMA చొప్పించడం విజయవంతమైంది. మీరు తదుపరి ఎండోట్రాచియల్ ట్యూబ్ (RSI) దశలను సమీక్షించాలనుకుంటున్నారా?",
    "CONTINUE TO ET TUBE": "ET ట్యూబ్ కోసం కొనసాగించండి",

    "RSI Step 1: Preparation": "RSI దశ 1: తయారీ",
    "Check equipment (SOAP ME):\n- Suction working?\n- Oxygen & BVM?\n- Airway tools (Laryngoscope/ETTs)?\n- Pharmacy (Induction/Paralytics)?\n- Monitoring (ECG/SpO2/ETCO2)?\n- Equipment (Stylet/Bougie)?": "పరికరాలను తనిఖీ చేయండి (SOAP ME):\n- సక్షన్ పనిచేస్తుందా?\n- ఆక్సిజన్ & BVM?\n- ఎయిర్‌వే పరికరాలు (లారింగోస్కోప్/ETTs)?\n- ఫార్మసీ (ఇండక్షన్/పారాలిటిక్స్)?\n- పర్యవేక్షణ (ECG/SpO2/ETCO2)?\n- పరికరాలు (స్టైలెట్/బూగీ)?",
    "PREPARED -> PREOXYGENATE": "తయారు -> ప్రీఆక్సిజనేట్",
    
    "RSI Step 2: Preoxygenation": "RSI దశ 2: ప్రీఆక్సిజనేషన్",
    "Administer 100% Oxygen for 3-5 minutes. Ensure SpO2 is maximized before paralysis. Nitrogen washout achieved?": "3-5 నిమిషాల పాటు 100% ఆక్సిజన్‌ను అందించండి. పక్షవాతం కంటే ముందు SpO2 గరిష్టంగా ఉండేలా చూసుకోండి. నైట్రోజన్ వాష్ అవుట్ సాధించబడిందా?",
    "YES (PRETREATMENT)": "అవును (ముందస్తు చికిత్స)",
    
    "RSI Step 3: Pretreatment": "RSI దశ 3: ముందస్తు చికిత్స",
    "Consider Fentanyl or Lidocaine to mitigate the physiologic response to laryngoscopy (if indicated). Ready to induce?": "లారింగోస్కోపీకి శారీరక ప్రతిస్పందనను తగ్గించడానికి ఫెంటానిల్ లేదా లిడోకాయిన్‌ను పరిగణించండి (సూచించినట్లయితే). ఇండక్షన్ కోసం సిద్ధంగా ఉన్నారా?",
    "READY TO INDUCE": "ఇండక్షన్ కోసం సిద్ధంగా ఉంది",
    
    "RSI Step 4: Induction & Paralysis": "RSI దశ 4: ఇండక్షన్ & పక్షవాతం",
    "Administer sedative agent (e.g., Etomidate) followed immediately by a rapid-acting paralytic (e.g., Succinylcholine or Rocuronium). Apnea achieved?": "సెడేటివ్ ఏజెంట్ (ఉదా., ఎటోమిడేట్) అందించండి, వెంటనే వేగంగా పనిచేసే పక్షవాతం (ఉదా., సక్సినైల్కోలిన్ లేదా రోకురోనియం) అందించండి. అప్నియా సాధించబడిందా?",
    "APNEA ACHIEVED (POSITION)": "అప్నియా సాధించబడింది (స్థానం)",
    
    "RSI Step 5: Positioning": "RSI దశ 5: పొజిషనింగ్",
    "Align the oral, pharyngeal, and laryngeal axes into the 'Sniffing Position'. Apply cricoid pressure if indicated. Optimal view possible?": "నోటి, ఫారింజియల్ మరియు లారింజియల్ అక్షాలను 'స్నిఫింగ్ పొజిషన్'లోకి సమలేఖనం చేయండి. సూచించినట్లయితే క్రికోయిడ్ ఒత్తిడిని వర్తింపజేయండి. సరైన వీక్షణ సాధ్యమేనా?",
    "YES (LARYNGOSCOPY)": "అవును (లారింగోస్కోపీ)",
    
    "RSI Step 6: Placement of Tube": "RSI దశ 6: ట్యూబ్ ప్లేస్‌మెంట్",
    "Perform laryngoscopy. Visualize vocal cords. Insert Endotracheal Tube (ETT) and remove stylet. Inflate cuff. Tube in place?": "లారింగోస్కోపీ నిర్వహించండి. వోకల్ కార్డ్స్‌ను ఊహించుకోండి. ఎండోట్రాచియల్ ట్యూబ్ (ETT) చొప్పించి, స్టైలెట్‌ను తొలగించండి. కఫ్ పెంచండి. ట్యూబ్ స్థానంలో ఉందా?",
    "YES (CONFIRMATION)": "అవును (నిర్ధారణ)",
    
    "RSI Step 7: Post-Intubation": "RSI దశ 7: పోస్ట్-ఇంట్యూబేషన్",
    "Confirm placement:\n- Bilateral chest rise?\n- Auscultation (5 points)?\n- Waveform Capnography (ETCO2)?\nSecure the tube and monitor vitals.": "ప్లేస్‌మెంట్‌ను నిర్ధారించండి:\n- ద్వైపాక్షిక ఛాతీ పెరుగుదల?\n- ఆస్కల్టేషన్ (5 పాయింట్లు)?\n- వేవ్‌ఫార్మ్ క్యాప్నోగ్రఫీ (ETCO2)?\nట్యూబ్‌ను సురక్షితం చేయండి మరియు వైటల్స్‌ను పర్యవేక్షించండి.",
    "COMPLETE RSI": "RSI పూర్తి చేయండి",
    
    "RSI Complete": "RSI పూర్తి",
    "ET Tube (RSI) protocol complete. Would you like to review the LMA (Supraglottic) steps next?": "ET ట్యూబ్ (RSI) ప్రోటోకాల్ పూర్తయింది. మీరు తదుపరి LMA (సుప్రాగ్లోటిక్) దశలను సమీక్షించాలనుకుంటున్నారా?",
    "CONTINUE TO LMA": "LMA కోసం కొనసాగించండి",

    # Common Dashboards & Categories
    "Level 1: Basic Life Saving": "స్థాయి 1: ప్రాథమిక జీవన రక్షణ",
    "Level 2: Emergency Management": "స్థాయి 2: అత్యవసర నిర్వహణ",
    "Level 3: Advanced Cardiac (ACLS)": "స్థాయి 3: అడ్వాన్స్‌డ్ కార్డియాక్ (ACLS)",
    "START HERE": "ఇక్కడ ప్రారంభించండి",
    "INTERMEDIATE": "మధ్యస్థం",
    "ADVANCED": "అడ్వాన్స్‌డ్",

    # Poisoning Expansion
    "Second Dose Administered": "రెండో డోస్ ఇవ్వబడింది",
    "Second dose of Naloxone given. Continue monitoring for 2-3 minutes. Any improvement in breathing?": "నలోక్సోన్ రెండో డోస్ ఇవ్వబడింది. 2-3 నిమిషాల పాటు పర్యవేక్షించడం కొనసాగించండి. శ్వాసలో ఏమైనా మెరుగుదల ఉందా?",
    "STILL NO IMPROVEMENT": "ఇంకా మెరుగుదల లేదు",

    # Trauma Expansion
    "Trauma Survey": "ట్రామా సర్వే",
    "Patient involved in a traumatic event. Ensure scene safety and BSI. Ready to start Primary Survey?": "రోగికి గాయం జరిగింది. దృశ్యం సురక్షితంగా ఉందని మరియు BSI ధరించారని నిర్ధారించుకోండి. ప్రైమరీ సర్వే ప్రారంభించడానికి సిద్ధంగా ఉన్నారా?",
    "START SURVEY": "సర్వే ప్రారంభించండి",
    "Step X: Exsanguination": "స్టెప్ X: విపరీతమైన రక్తస్రావం",
    "Is there massive life-threatening bleeding? Apply a tourniquet or direct pressure immediately! Controlled?": "ప్రాణాపాయం కలిగించే రక్తస్రావం ఉందా? వెంటనే టోర్నీకీ లేదా ప్రత్యక్ష ఒత్తిడిని ఉపయోగించండి! రక్తస్రావం నియంత్రించబడిందా?",
    "YES, CONTROLLED": "అవును, నియంత్రించబడింది",
    "NOT CONTROLLED": "నియంత్రించబడలేదు",
    "Step A: Airway & C-Spine": "స్టెప్ A: వాయుమార్గం & C-స్పైన్",
    "Assess airway and stabilize Cervical Spine. Use Jaw Thrust if needed. Airway patent and spine stabilized?": "వాయుమార్గాన్ని అంచనా వేయండి మరియు గర్భాశయ వెన్నెముకను స్థిరపరచండి. అవసరమైతే జా థ్రస్ట్ ఉపయోగించండి. వాయుమార్గం తెరిచి ఉందా మరియు వెన్నెముక స్థిరంగా ఉందా?",
    "YES, SECURED": "అవును, సురక్షితం",
    "NEED AIRWAY HELP": "వాయుమార్గ సహాయం అవసరం",
    "Step B: Breathing": "స్టెప్ B: శ్వాస",
    "Assess for tension pneumothorax, open chest wounds, or flail chest. Provide oxygen. Breathing adequate?": "టెన్షన్ న్యూమోథొరాక్స్, ఓపెన్ చెస్ట్ గాయాలు లేదా ఫ్లైల్ చెస్ట్ కోసం తనిఖీ చేయండి. ఆక్సిజన్ అందించండి. శ్వాస సరిగ్గా ఉందా?",
    "YES, ADEQUATE": "అవును, సరిగ్గా ఉంది",
    "NO, ASSIST VENTILATION": "కాదు, శ్వాసకు సహాయం చేయండి",
    "Step C: Circulation": "స్టెప్ C: రక్త ప్రసరణ",
    "Check pulse and skin. Look for hidden bleeding (Pelvis, Long bones). Apply pelvic binder if needed. Stable?": "పల్స్ మరియు చర్మాన్ని తనిఖీ చేయండి. దాగి ఉన్న రక్తస్రావం (పెల్విస్, లాంగ్ బోన్స్) కోసం చూడండి. అవసరమైతే పెల్విక్ బైండర్ ఉపయోగించండి. స్థిరంగా ఉందా?",
    "YES, STABLE": "అవును, స్థిరంగా ఉంది",
    "NO, TREAT SHOCK": "కాదు, షాక్ కోసం చికిత్స చేయండి",
    "Step D: Disability": "స్టెప్ D: వైకల్యం (మెదడు)",
    "Check GCS/AVPU and pupils. Note any focal deficits. Neuro status recorded?": "GCS/AVPU మరియు కనుపాపలను తనిఖీ చేయండి. ఏవైనా నాడీ సంబంధిత సమస్యలను గమనించండి. న్యూరో స్థితి రికార్డ్ చేయబడిందా?",
    "Step E: Exposure": "స్టెప్ E: బాహ్య పరీక్ష",
    "Expose injuries but prevent hypothermia. Keep the patient warm! Ready for Secondary Survey?": "గాయాలను చూడటానికి బట్టలు తొలగించండి కానీ హైపోథెర్మియాను నిరోధించండి. రోగిని వెచ్చగా ఉంచండి! సెకండరీ సర్వే కోసం సిద్ధంగా ఉన్నారా?",
    "CONTINUE TO SECONDARY": "సెకండరీ సర్వేకు కొనసాగించండి",
    "Primary trauma management complete. Follow hospital protocols for definitive care.": "ప్రైమరీ ట్రామా మేనేజ్‌మెంట్ పూర్తయింది. నిశ్చయాత్మక సంరక్షణ కోసం హాస్పిటల్ ప్రోటోకాల్స్‌ను అనుసరించండి.",
    # Trauma Intervention Steps
    "Bleeding Intervention": "రక్తస్రావం నివారణ",
    "Apply a tourniquet higher up or use a second pressure bandage. If bleeding is in a junction (neck/groin), use hemostatic gauze. Controlled now?": "పైభాగంలో టోర్నీకీని వర్తింపజేయండి లేదా రెండో ప్రెజర్ బ్యాండేజీని ఉపయోగించండి. రక్తస్రావం జంక్షన్ (మెడ/గజ్జ)లో ఉంటే, హెమోస్టాటిక్ గాజ్‌ను ఉపయోగించండి. ఇప్పుడు నియంత్రించబడిందా?",
    "STILL BLEEDING": "ఇంకా రక్తస్రావం అవుతోంది",
    "Ventilation Support": "శ్వాస సహాయం",
    "Use Bag-Valve-Mask (BVM) to assist breathing. Ensure chest rise. If tension pneumothorax suspected, prepare for needle decompression. Ready?": "శ్వాసకు సహాయం చేయడానికి బ్యాగ్-వాల్వ్-మాస్క్ (BVM) ఉపయోగించండి. ఛాతీ పెరుగుతోందని నిర్ధారించుకోండి. టెన్షన్ న్యూమోథొరాక్స్ అని అనుమానం ఉంటే, నీడిల్ డికంప్రెషన్ కోసం సిద్ధం చేయండి. సిద్ధంగా ఉన్నారా?",
    "VENTILATION STARTED": "శ్వాస సహాయం ప్రారంభమైంది",
    "Shock Management": "షాక్ నిర్వహణ",
    "Establish two large-bore IVs. Consider warm crystalloids or blood products. Apply pelvic binder or splints if needed. Ready?": "రెండు లార్జ్-బోర్ IVలను ఏర్పాటు చేయండి. వార్మ్ క్రిస్టలాయిడ్స్ లేదా రక్త ఉత్పత్తులను పరిగణించండి. అవసరమైతే పెల్విక్ బైండర్ లేదా స్ప్లింట్‌లను వర్తింపజేయండి. సిద్ధంగా ఉన్నారా?",
    "STABILIZING": "స్థిరపరుస్తున్నాము",

    # Poisoning Failed
    "No Response to Naloxone": "నలోక్సోన్‌కు ప్రతిస్పందన లేదు",
    "Patient is not responding to Naloxone. Start Bag-Valve-Mask (BVM) ventilation, consider advanced airway, and initiate rapid transport immediately. Ready?": "రోగి నలోక్సోన్‌కు ప్రతిస్పందించడం లేదు. బ్యాగ్-వాల్వ్-మాస్క్ (BVM) శ్వాసను ప్రారంభించండి, అడ్వాన్స్‌డ్ వాయుమార్గాన్ని పరిగణించండి మరియు వెంటనే వేగవంతమైన రవాణాను ప్రారంభించండి. సిద్ధంగా ఉన్నారా?",
    "READY FOR TRANSPORT": "రవాణాకు సిద్ధంగా ఉంది",
    "FINISH POISONING": "విషప్రయోగం మాడ్యూల్ పూర్తి చేయండి",
    "FINISH MODULE": "మాడ్యూల్ పూర్తి చేయండి",
    "Poisoning Complete": "విషప్రయోగం మాడ్యూల్ పూర్తయింది",
    "Poisoning management protocol complete. Would you like to review Snake Bite management steps next?": "విషప్రయోగం నిర్వహణ ప్రోటోకాల్ పూర్తయింది. మీరు తదుపరి పాము కాటు నిర్వహణ దశలను సమీక్షించాలనుకుంటున్నారా?",
    "CONTINUE TO SNAKE BITE": "పాము కాటు మాడ్యూల్‌కు కొనసాగించండి",
    "Assess Airway, Breathing, and Circulation for immediate life threats. Proceed?": "తక్షణ ప్రాణాపాయం కోసం వాయుమార్గం, శ్వాస మరియు రక్త ప్రసరణను అంచనా వేయండి. కొనసాగించాలా?",
    "FINISH SNAKE BITE": "పాము కాటు మాడ్యూల్ పూర్తి చేయండి",
    "Snake Bite Complete": "పాము కాటు మాడ్యూల్ పూర్తయింది",
    "Snake bite management protocol complete. Would you like to review general Poisoning management steps next?": "పాము కాటు నిర్వహణ ప్రోటోకాల్ పూర్తయింది. మీరు తదుపరి సాధారణ విషప్రయోగం నిర్వహణ దశలను సమీక్షించాలనుకుంటున్నారా?",
    "CONTINUE TO POISONING": "విషప్రయోగం మాడ్యూల్‌కు కొనసాగించండి",
}

# Load external JSON if exists
json_path = os.path.join(os.path.dirname(__file__), 'po_translations.json')
if os.path.exists(json_path):
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            po_data = json.load(f)
            # Use JSON to fill gaps in hardcoded mapping
            for k, v in po_data.items():
                if k not in TELUGU_MAPPINGS:
                    TELUGU_MAPPINGS[k] = v
    except Exception as e:
        logger.error(f"Failed to load po_translations.json: {e}")

def translate_to_te(text):
    if not text:
        return text
    normalized_text = str(text).replace('\r\n', '\n').strip()
    return TELUGU_MAPPINGS.get(normalized_text, text)

def translate_dict(data, lang='en'):
    is_telugu = lang and lang.startswith('te')
    if isinstance(data, dict):
        new_data = {}
        for k, v in data.items():
            translatable_keys = [
                'title', 'question', 'label', 'description', 'notice', 'action_label', 
                'name', 'tag', 'footer_note', 'text', 'message', 'content', 'value',
                'placeholder', 'hint', 'instruction', 'feedback', 'response', 'answer',
                'option', 'choice', 'header', 'caption', 'summary', 'detail'
            ]
            if k in translatable_keys:
                if isinstance(v, (str, bytes)) or hasattr(v, '__html__') or not isinstance(v, (dict, list)):
                    text_value = str(v)
                    new_data[k] = translate_to_te(text_value) if is_telugu else text_value
                else:
                    new_data[k] = translate_dict(v, lang)
            else:
                new_data[k] = translate_dict(v, lang)
        return new_data
    elif isinstance(data, list):
        return [translate_dict(item, lang) for item in data]
    else:
        if hasattr(data, '__class__') and '__proxy__' in str(type(data)):
            return str(data)
        return data