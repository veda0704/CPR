import React, { useState, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import LoadingSpinner from './LoadingSpinner';
import Confetti from './Confetti';
import ChoiceCards from './ChoiceCards';
import { getStep, logout } from '../services/api';
import { ArrowLeft, Home, CheckCircle, Star, Trophy, ArrowRight, ChevronRight, Play, Pause, RotateCcw, AlertTriangle, Info, Volume2, VolumeX, AlertCircle, Sun, Moon, User, LogOut, Clock, Shield, Activity } from 'lucide-react';
import Footer from './Footer';
import ThemeToggle from './ThemeToggle';
import LanguageSelector from './LanguageSelector';
import SettingsPanel from './SettingsPanel';
import { Settings } from 'lucide-react';
import AnimatedECG from './AnimatedECG';
import { getModuleStatus, setModuleStatus, setModuleProgress } from '../utils/moduleStatus';
import iaclsLogo from '../assets/iacls-logo.png';

// --- Contextual completion info based on which module finished ---
const getCompletionContent = (stepTitle, lang) => {
  const map = {
    en: {
      default: { emoji: '🏆', headline: 'Module Complete!', sub: 'You have successfully finished this training module.' },
      bls: { emoji: '❤️', headline: 'BLS Complete!', sub: 'Basic Life Support module finished successfully.' },
      airway: { emoji: '💨', headline: 'Airway Module Complete!', sub: 'Airway management protocols reviewed.' },
      cardiac: { emoji: '⚡', headline: 'Cardiac Algorithm Complete!', sub: 'You have mastered the cardiac emergency protocols.' },
      stroke: { emoji: '🧠', headline: 'Stroke Protocol Complete!', sub: 'Stroke assessment and management reviewed.' },
      acs: { emoji: '🩺', headline: 'ACS Protocol Complete!', sub: 'Acute Coronary Syndrome module finished.' },
      ecg: { emoji: '📈', headline: 'ECG Training Complete!', sub: 'ECG waves and rhythm analysis reviewed.' },
      trauma: { emoji: '🚑', headline: 'Trauma Survey Complete!', sub: 'Trauma management protocols reviewed.' },
      nls: { emoji: '👶', headline: 'Neonatal Support Complete!', sub: 'Neonatal Life Support module finished.' },
      poison: { emoji: '🧪', headline: 'Poisoning Module Complete!', sub: 'Toxicology management protocols reviewed.' },
      disaster: { emoji: '🆘', headline: 'Disaster Management Complete!', sub: 'Triage and disaster response reviewed.' },
      h5t5: { emoji: '✅', headline: '5H & 5T Check Complete!', sub: 'Reversible causes of cardiac arrest reviewed.' },
    },
    te: {
      default: { emoji: '🏆', headline: 'మాడ్యూల్ పూర్తయింది!', sub: 'మీరు ఈ శిక్షణ మాడ్యూల్‌ను విజయవంతంగా ముగించారు.' },
      bls: { emoji: '❤️', headline: 'BLS పూర్తయింది!', sub: 'బేసిక్ లైఫ్ సపోర్ట్ మాడ్యూల్ విజయవంతంగా ముగిసింది.' },
      airway: { emoji: '💨', headline: 'ఎయిర్‌వే మాడ్యూల్ పూర్తయింది!', sub: 'వాయుమార్గ నిర్వహణ ప్రోటోకాల్స్ సమీక్షించబడ్డాయి.' },
      cardiac: { emoji: '⚡', headline: 'కార్డియాక్ అల్గోరిథం పూర్తయింది!', sub: 'మీరు కార్డియాక్ ఎమర్జెన్సీ ప్రోటోకాల్స్‌లో ప్రావీణ్యం సంపాదించారు.' },
      stroke: { emoji: '🧠', headline: 'స్ట్రోక్ ప్రోటోకాల్ పూర్తయింది!', sub: 'స్ట్రోక్ అంచనా మరియు నిర్వహణ సమీక్షించబడ్డాయి.' },
      acs: { emoji: '🩺', headline: 'ACS ప్రోటోకాల్ పూర్తయింది!', sub: 'అక్యూట్ కోరోనరీ సిండ్రోమ్ మాడ్యూల్ ముగిసింది.' },
      ecg: { emoji: '📈', headline: 'ECG శిక్షణ పూర్తయింది!', sub: 'ECG తరంగాలు మరియు రిథమ్ అనాలిసిస్ సమీక్షించబడ్డాయి.' },
      trauma: { emoji: '🚑', headline: 'ట్రామా సర్వే పూర్తయింది!', sub: 'ట్రామా మేనేజ్‌మెంట్ ప్రోటోకాల్స్ సమీక్షించబడ్డాయి.' },
      nls: { emoji: '👶', headline: 'నియోనాటల్ సపోర్ట్ పూర్తయింది!', sub: 'నియోనాటల్ లైఫ్ సపోర్ట్ మాడ్యూల్ ముగిసింది.' },
      poison: { emoji: '🧪', headline: 'విషప్రయోగం మాడ్యూల్ పూర్తయింది!', sub: 'టాక్సికాలజీ మేనేజ్‌మెంట్ ప్రోటోకాల్స్ సమీక్షించబడ్డాయి.' },
      disaster: { emoji: '🆘', headline: 'డిజాస్టర్ మేనేజ్‌మెంట్ పూర్తయింది!', sub: 'ట్రయాజ్ మరియు డిజాస్టర్ రెస్పాన్స్ సమీక్షించబడ్డాయి.' },
      h5t5: { emoji: '✅', headline: '5H & 5T తనిఖీ పూర్తయింది!', sub: 'కార్డియాక్ అరెస్ట్ యొక్క రివర్సిబుల్ కారణాలు సమీక్షించబడ్డాయి.' },
    }
  };

  const t_func = map[lang] || map.en;
  const lower = (stepTitle || '').toLowerCase();

  let content = t_func.default;
  if (lower.includes('bls') || lower.includes('responsiveness') || lower.includes('cpr') || lower.includes('pulse')) content = t_func.bls;
  else if (lower.includes('airway') || lower.includes('breathing') || lower.includes('choking') || lower.includes('lma') || lower.includes('rsi')) content = t_func.airway;
  else if (lower.includes('cardiac') || lower.includes('tachycard') || lower.includes('bradycard') || lower.includes('vf') || lower.includes('vt') || lower.includes('shock') || lower.includes('rhythm') || lower.includes('rosc')) content = t_func.cardiac;
  else if (lower.includes('stroke')) content = t_func.stroke;
  else if (lower.includes('acs') || lower.includes('mona') || lower.includes('coronary')) content = t_func.acs;
  else if (lower.includes('ecg') || lower.includes('wave') || lower.includes('paper')) content = t_func.ecg;
  else if (lower.includes('trauma')) content = t_func.trauma;
  else if (lower.includes('nls') || lower.includes('neonatal') || lower.includes('baby') || lower.includes('placental') || lower.includes('golden minute')) content = t_func.nls;
  else if (lower.includes('poison') || lower.includes('snake') || lower.includes('toxin') || lower.includes('naloxone') || lower.includes('atropine')) content = t_func.poison;
  else if (lower.includes('disaster') || lower.includes('triage') || lower.includes('preparation') || lower.includes('command')) content = t_func.disaster;
  else if (lower.includes('5h') || lower.includes('5t') || lower.includes('hypovolemia') || lower.includes('hypothermia') || lower.includes('thrombosis')) content = t_func.h5t5;

  return content;
};

const VALID_INTERACTIVE_COMPONENTS = ['ecg_monitor', 'patient_type_selector', 'choice_cards'];

const normalizeStepData = (rawData) => {
  if (!rawData || typeof rawData !== 'object') {
    throw new Error('Invalid step payload');
  }

  let rawChoices = rawData.choices;
  if (!Array.isArray(rawChoices) || rawChoices.length === 0) {
    if (rawData.interactive_props) {
      rawChoices = rawData.interactive_props.choices || rawData.interactive_props.options;
    }
  }

  const choices = Array.isArray(rawChoices)
    ? rawChoices.filter((choice) => choice && typeof choice === 'object').map((choice) => ({
      label: String(choice.label || choice.text || ''),
      text: String(choice.text || choice.label || ''),
      description: String(choice.description || ''),
      icon: String(choice.icon || choice.image || ''),
      next: String(choice.next || 'dashboard'),
      color: String(choice.color || 'primary'),
      isExit: Boolean(choice.isExit),
    }))
    : [];

  const interactiveComponent = typeof rawData.interactive_component === 'string' && VALID_INTERACTIVE_COMPONENTS.includes(rawData.interactive_component)
    ? rawData.interactive_component
    : null;

  const interactiveProps = rawData.interactive_props && typeof rawData.interactive_props === 'object'
    ? rawData.interactive_props
    : null;

  // Extract step number from ID if possible (e.g., adult_choking_step5 -> 5)
  let currentStep = rawData.current_step;
  if (!currentStep && typeof rawData.id === 'string') {
    const match = rawData.id.match(/(\d+)$/);
    if (match) currentStep = parseInt(match[1], 10);
  }

  return {
    id: rawData.id ? String(rawData.id) : '',
    title: typeof rawData.title === 'string' ? rawData.title : '',
    question: typeof rawData.question === 'string' ? rawData.question : '',
    audio_url: typeof rawData.audio_url === 'string' ? rawData.audio_url : null,
    video: typeof rawData.video === 'string' ? rawData.video : null,
    interactive_component: interactiveComponent,
    interactive_props: interactiveProps,
    time_limit: Number.isInteger(rawData.time_limit) ? rawData.time_limit : null,
    timeout_next: typeof rawData.timeout_next === 'string' ? rawData.timeout_next : null,
    current_step: currentStep || 1,
    total_steps: rawData.total_steps || 8,
    choices,
  };
};

// --- Main Component ---
const ACLSWorkflow = ({ user, setUser, theme, toggleTheme, themeColor, applyThemeColor }) => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const { '*': stepId } = useParams();
  const [stepData, setStepData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showCompletion, setShowCompletion] = useState(false);
  const [sceneTime, setSceneTime] = useState(0);
  const [completionInfo, setCompletionInfo] = useState(null);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [isPlaying, setIsPlaying] = useState(true);
  const [voiceEnabled, setVoiceEnabled] = useState(localStorage.getItem('voiceEnabled') === 'true');
  const voiceEnabledRef = useRef(voiceEnabled);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const audioRef = useRef(null);
  const videoRef = useRef(null);
  const completionRef = useRef(null);
  const isMounted = useRef(true);

  // Functional Timer Logic
  useEffect(() => {
    const timer = setInterval(() => {
      setSceneTime(prev => prev + 1);
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTime = (seconds) => {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    return [h, m, s].map(v => v < 10 ? '0' + v : v).join(':');
  };

  useEffect(() => {
    isMounted.current = true;
    const fetchStep = async () => {
      setLoading(true);
      try {
        const res = await getStep(stepId);
        const sanitized = normalizeStepData(res.data);
        if (!sanitized.id) {
          throw new Error('Missing step id');
        }
        if (isMounted.current) {
          setStepData(sanitized);
          
          // Dynamic Progress Tracking for every module
          const moduleId = getModuleIdFromStep(sanitized.id || stepId);
          if (moduleId && sanitized.total_steps > 0) {
            const calculatedProgress = Math.round((sanitized.current_step / sanitized.total_steps) * 100);
            setModuleProgress(moduleId, calculatedProgress, user?.email);
          }
        }
      } catch (err) {
        console.error('Step validation failed', err);
        if (isMounted.current) navigate('/dashboard');
      } finally {
        if (isMounted.current) setLoading(false);
      }
    };

    // Add timeout to prevent infinite loading
    const timeout = setTimeout(() => {
      if (isMounted.current) setLoading(false);
    }, 15000); // 15 second timeout for steps

    if (stepId) fetchStep();
    return () => {
      isMounted.current = false;
      clearTimeout(timeout);
    };
  }, [stepId, navigate, i18n.language]);

  const moduleMap = {
    scene_safety: 'scene_safety',
    abcde: 'abcde',
    bls: 'bls',
    choking: 'choking',
    airway: 'airway',
    adv_airway: 'adv_airway',
    trauma: 'trauma',
    poisoning: 'poisoning',
    snake_bite: 'snake_bite',
    stroke: 'stroke',
    disaster: 'disaster',
    delivery: 'delivery',
    ecg: 'ecg',
    rhythms: 'rhythms',
    cardiac_alg: 'cardiac_alg',
    h5t5: 'h5t5',
    acls: 'acls',
  };

  const getModuleIdFromStep = (stepIdentifier) => {
    if (!stepIdentifier) return null;
    const normalId = stepIdentifier.toLowerCase();
    
    // Check specific complex IDs first to avoid partial matches
    if (normalId.startsWith('ecg_rhythms')) return 'ecg_rhythms';
    if (normalId.startsWith('adv_airway')) return 'adv_airway';
    if (normalId.startsWith('cardiac_alg')) return 'cardiac_alg';
    if (normalId.startsWith('scene_safety')) return 'scene_safety';
    if (normalId.startsWith('snake_bite')) return 'snake_bite';
    
    // Standard mapping
    if (normalId === '1') return 'acls';
    if (normalId.startsWith('abcde')) return 'abcde';
    if (normalId.startsWith('bls')) return 'bls';
    if (normalId.startsWith('choking')) return 'choking';
    if (normalId.startsWith('airway')) return 'airway';
    if (normalId.startsWith('trauma')) return 'trauma';
    if (normalId.startsWith('poisoning')) return 'poisoning';
    if (normalId.startsWith('stroke')) return 'stroke';
    if (normalId.startsWith('disaster')) return 'disaster';
    if (normalId.startsWith('delivery')) return 'delivery';
    if (normalId.startsWith('ecg')) return 'ecg_rhythms'; // Map basic ecg to rhythms module
    if (normalId.startsWith('rhythms')) return 'ecg_rhythms';
    if (normalId.startsWith('h5t5')) return 'h5t5';
    
    return Object.keys(moduleMap).find((moduleKey) => normalId.includes(moduleKey)) || null;
  };

  const stopAudio = () => {
    if (audioRef.current) {
      try {
        audioRef.current.pause();
        audioRef.current.currentTime = 0;
        audioRef.current.onended = null;
        audioRef.current.onerror = null;
      } catch (e) {
        console.warn("Error stopping audio:", e);
      }
      audioRef.current = null;
      setIsSpeaking(false);
    }
  };

  const handlePlayVoice = React.useCallback(async () => {
    stopAudio();
    if (!voiceEnabledRef.current || !isMounted.current || !stepData?.audio_url) return;

    try {
      const audio = new Audio(stepData.audio_url);
      audioRef.current = audio;
      setIsSpeaking(true);

      audio.onended = () => {
        if (isMounted.current) setIsSpeaking(false);
      };

      audio.onerror = () => {
        console.error("Audio playback error");
        if (isMounted.current) setIsSpeaking(false);
      };

      const playPromise = audio.play();
      if (playPromise !== undefined) {
        playPromise.catch(error => {
          console.warn("Autoplay blocked or playback interrupted:", error);
          if (isMounted.current) setIsSpeaking(false);
        });
      }
    } catch (err) {
      console.error('Speech error:', err);
      if (isMounted.current) setIsSpeaking(false);
    }
  }, [stepData?.audio_url]);

  useEffect(() => {
    if (stepData) {
      const moduleId = getModuleIdFromStep(stepData.id || stepId);
      if (moduleId && getModuleStatus(moduleId, user?.email) !== 'completed') {
        setModuleStatus(moduleId, 'in_progress', user?.email);
      }
    }
    
    // Guard against rapid-fire audio during navigation
    const playTimeout = setTimeout(() => {
      if (stepData && voiceEnabled) {
        handlePlayVoice();
      }
    }, 100);

    return () => {
      clearTimeout(playTimeout);
      stopAudio();
    };
  }, [stepData?.id, voiceEnabled, handlePlayVoice, stepId]);

  // Audio Playback effect removed for manual trigger only

  const handleChoice = (nextStep, choice) => {
    stopAudio();
    
    // Track sub-module completion for Rhythms & Blocks
    if (nextStep === 'rhythms_start' || nextStep === 'dashboard') {
      const currentStep = stepData?.id || stepId;
      if (currentStep && (currentStep.startsWith('rhythms_') || currentStep === 'rhythms_start')) {
        setModuleStatus(currentStep, 'completed', user?.email);
      }
    }

    if (nextStep === 'dashboard') {
      const moduleId = getModuleIdFromStep(stepData?.id || stepId);
      
      // If it's a legitimate completion (not just a BACK button), mark as complete
      if (moduleId && !choice?.label?.toLowerCase()?.includes('back')) {
        setModuleStatus(moduleId, 'completed', user?.email);
      }

      if (choice?.isExit) {
        navigate('/dashboard');
        return;
      }

      const info = getCompletionContent(stepData?.title, i18n.language);
      setCompletionInfo(info);
      setShowCompletion(true);
      window.scrollTo({ top: 0, behavior: 'smooth' });
      return;
    } else {
      const currentModuleId = getModuleIdFromStep(stepData?.id || stepId);
      const targetModuleId = getModuleIdFromStep(nextStep);
      const label = choice?.label?.toLowerCase() || choice?.text?.toLowerCase() || '';

      // If transitioning to a new module (Continue to Next), mark current as complete
      if (currentModuleId && targetModuleId && currentModuleId !== targetModuleId && !label.includes('back')) {
        setModuleStatus(currentModuleId, 'completed', user?.email);
      } else if (label.includes('continue') && !label.includes('back') && currentModuleId) {
        setModuleStatus(currentModuleId, 'completed', user?.email);
      }

      navigate(`/acls/${nextStep}`);
    }
  };

  const toggleVoice = () => {
    const newState = !voiceEnabled;
    setVoiceEnabled(newState);
    voiceEnabledRef.current = newState;
    localStorage.setItem('voiceEnabled', newState);

    if (!newState) {
      stopAudio();
    } else {
      handlePlayVoice();
    }
  };

  const handleGoToDashboard = () => {
    stopAudio();
    navigate('/dashboard');
  };


  if (loading) return <LoadingSpinner message="Loading Step" />;
  if (!stepData) return null;

  if (showCompletion && completionInfo) {
    return (
      <div className="completion-overlay">
        <Confetti />
        <div className="completion-card">
          <div className="completion-emoji-ring">
            <span className="completion-emoji">{completionInfo.emoji}</span>
          </div>
          <div className="completion-stars">
            {[0, 1, 2].map(i => (
              <Star
                key={i}
                size={32}
                className="completion-star-icon"
                style={{ animationDelay: `${i * 0.15}s` }}
              />
            ))}
          </div>
          <h1 className="completion-headline">{completionInfo.headline}</h1>
          <p className="completion-sub">{completionInfo.sub}</p>
          
          <div className="completion-module-badge">
            <CheckCircle size={20} style={{ color: 'var(--success)' }} />
            <span>{t(stepData.title)}</span>
          </div>

          <div className="stack" style={{ width: '100%', alignItems: 'center' }}>
            <button className="clinical-button" onClick={handleGoToDashboard} style={{ height: '60px', width: '100%', maxWidth: '320px' }}>
              <Home size={20} />
              {i18n.language === 'te' ? 'డాష్‌బోర్డ్‌కు తిరిగి వెళ్లండి' : 'Back to Dashboard'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // --- Normal Step View ---
  return (
    <div className="simulator-page medical-bg">
      <nav className="floating-nav animate-reveal">
        <div style={{ display: 'flex', alignItems: 'center', gap: '24px', flex: 1 }}>
          <div className="nav-brand">
            <img 
              src={iaclsLogo} 
              alt="IACLS Logo" 
              style={{ 
                height: '54px', 
                width: 'auto', 
                objectFit: 'contain',
                filter: 'brightness(0) invert(1) drop-shadow(0 0 0.5px white)'
              }} 
            />
          </div>
          <div style={{ display: 'flex', gap: '10px', marginLeft: '12px', paddingLeft: '20px', borderLeft: '1px solid rgba(255,255,255,0.2)' }}>
            {!stepId.includes('_start') && !stepId.includes('_initial') && stepId !== '1' && (
              <button className="icon-btn" onClick={() => { stopAudio(); navigate(-1); }} title={t('back')} style={{ background: 'rgba(255,255,255,0.15)', color: 'white', border: '1px solid rgba(255,255,255,0.3)', width: '42px', height: '42px', borderRadius: '12px' }}>
                <ArrowLeft size={20} />
              </button>
            )}
            <button className="icon-btn" onClick={() => { stopAudio(); navigate('/dashboard'); }} title={t('home')} style={{ background: 'rgba(255,255,255,0.15)', color: 'white', border: '1px solid rgba(255,255,255,0.3)', width: '42px', height: '42px', borderRadius: '12px' }}>
              <Home size={20} />
            </button>
          </div>
        </div>

        <div className="floating-nav-center">
          <div className="floating-nav-title" style={{ padding: '8px 32px' }}>{t(stepData.title) || t('Simulation')}</div>
        </div>

        <div className="floating-nav-right" style={{ flex: 1, justifyContent: 'flex-end', gap: '12px' }}>
          <div className="nav-timer-pill" style={{ background: 'rgba(255,255,255,0.1)', border: '1px solid rgba(255,255,255,0.2)', color: 'white', minWidth: '100px' }}>
            <Clock size={16} />
            <span>{formatTime(sceneTime)}</span>
          </div>

          <button 
            className="icon-btn" 
            onClick={() => setIsSettingsOpen(true)}
            title={t('settings')}
            style={{ background: 'rgba(255,255,255,0.15)', color: 'white', border: '1px solid rgba(255,255,255,0.3)', width: '42px', height: '42px', borderRadius: '12px' }}
          >
            <Settings size={20} />
          </button>
        </div>
      </nav>

      <SettingsPanel 
        isOpen={isSettingsOpen} 
        onClose={() => setIsSettingsOpen(false)} 
        theme={theme} 
        toggleTheme={toggleTheme} 
        currentPrimary={themeColor}
        applyThemeColor={applyThemeColor}
      />

      <main key={stepData.id} className="simulator-main animate-step">
        <div className="app-container">
          {/* CASE 1: Selector / Category Grid (For specific hubs) */}
          {(stepData.interactive_component === 'choice_cards' || stepData.interactive_component === 'patient_type_selector') ? (
            <div className="selector-layout animate-reveal">
              <div className="selector-grid-container" style={{ padding: '0 20px' }}>
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '20px', marginBottom: '20px' }}>
                  <h2 className="selector-grid-title" style={{ margin: 0 }}>{t(stepData.question)}</h2>
                  <button 
                    className={`icon-btn ${voiceEnabled ? 'active' : ''}`} 
                    onClick={toggleVoice} 
                    style={{ 
                      flexShrink: 0, 
                      width: '42px', 
                      height: '42px', 
                      borderRadius: '12px', 
                      background: voiceEnabled ? 'var(--primary-soft)' : 'rgba(0,0,0,0.03)',
                      border: '1px solid rgba(0,0,0,0.05)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      marginBottom: '24px'
                    }}
                  >
                    {voiceEnabled ? <Volume2 size={20} color="var(--primary)" /> : <VolumeX size={20} color="var(--text-muted)" />}
                  </button>
                </div>
                <div className="selector-grid">
                  {(stepData.interactive_props?.options || []).map((choice, idx) => (
                    <div 
                      key={idx} 
                      className="selector-card animate-reveal" 
                      onClick={() => handleChoice(choice.next, choice)}
                      style={{ animationDelay: `${idx * 0.1}s` }}
                    >
                      <div className="selector-icon-box">
                        {(choice.image || choice.icon) ? (
                          <img src={choice.image || choice.icon} alt="" />
                        ) : (
                          <Activity size={32} />
                        )}
                      </div>
                      <div className="selector-content">
                        <h3 className="selector-title">{t(choice.label || choice.text)}</h3>
                        <p className="selector-desc">{t(choice.description)}</p>
                      </div>
                      <div className="selector-action-btn">{t(choice.action_label || 'Proceed')}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Fixed Bottom Action Area - Only for FINISH button on Rhythms Hub */}
              {stepId === 'rhythms_start' && (
                <div className="fixed-action-area">
                  {stepData.choices
                    .filter(choice => choice.next === 'dashboard')
                    .map((choice, idx) => (
                        <div key={idx} style={{ textAlign: 'center', width: '100%', maxWidth: '360px' }}>
                          <button 
                            className={`simulator-btn ${choice.color || 'success'}`}
                            onClick={() => handleChoice(choice.next, choice)}
                            style={{ 
                              width: '100%', 
                              minHeight: '44px',
                              borderRadius: '12px'
                            }}
                          >
                            {t(choice.label || choice.text)}
                          </button>
                        </div>
                    ))}
                </div>
              )}
            </div>
          ) : (
            /* CASE 2: Clinical Scenario (Split-Screen) */
            <div className="acls-workflow-layout has-media">
              
              {/* Left Side: Media and Info */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div className="simulator-media-container" style={{ 
                  width: '100%', 
                  aspectRatio: '16/10',
                  maxHeight: '300px',
                  overflow: 'hidden', 
                  borderRadius: '24px', 
                  border: '1px solid rgba(0,0,0,0.08)',
                  background: '#0F172A',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  boxShadow: 'inset 0 0 40px rgba(0,0,0,0.2)'
                }}>
                  {stepData.interactive_component === 'ecg_monitor' ? (
                    <div style={{ width: '100%', height: '100%', background: '#1A1716' }}>
                      <AnimatedECG rhythms={stepData.interactive_props?.rhythms || ['nsr']} />
                    </div>
                  ) : stepData.video ? (
                    stepData.video.match(/\.(jpeg|jpg|gif|png|webp|svg)$/i) ? (
                      <img src={stepData.video} alt="" style={{ width: 'auto', height: 'auto', maxWidth: '100%', maxHeight: '100%', objectFit: 'contain' }} />
                    ) : (
                      <video ref={videoRef} src={stepData.video} autoPlay loop muted playsInline style={{ width: 'auto', height: 'auto', maxWidth: '100%', maxHeight: '100%', objectFit: 'contain' }} />
                    )
                  ) : (
                    <div style={{ width: '100%', height: '200px', display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: 0.2 }}>
                      <AnimatedECG rhythms={stepData.interactive_props?.rhythms || ['nsr']} />
                    </div>
                  )}
                </div>
              </div>

              <div style={{ 
                padding: '20px 0', 
                display: 'flex', 
                flexDirection: 'column', 
                gap: '12px', 
                width: '100%',
                maxWidth: '480px',
                margin: '0 auto',
                maxHeight: 'calc(100vh - 160px)',
                overflowY: 'auto'
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '16px' }}>
                  <h2 className="simulator-question" style={{ margin: 0, flex: 1, fontSize: '21px', fontWeight: 850, color: 'var(--text-main)', lineHeight: 1.5, letterSpacing: '-0.015em', whiteSpace: 'pre-line' }}>
                    {t(stepData.question)}
                  </h2>
                  <button 
                    className={`icon-btn ${voiceEnabled ? 'active' : ''}`} 
                    onClick={toggleVoice} 
                    style={{ 
                      flexShrink: 0, 
                      width: '42px', 
                      height: '42px', 
                      borderRadius: '12px', 
                      background: voiceEnabled ? 'var(--primary-soft)' : 'rgba(0,0,0,0.03)',
                      border: '1px solid rgba(0,0,0,0.05)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    {voiceEnabled ? <Volume2 size={20} color="var(--primary)" /> : <VolumeX size={20} color="var(--text-muted)" />}
                  </button>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  {stepData.choices
                    .filter(choice => {
                      if (stepId === 'rhythms_start' && choice.next === 'dashboard') return true;
                      if (stepId.includes('_start') && choice.next === 'dashboard') return false;
                      return true;
                    })
                    .map((choice, idx) => (
                    <button
                      key={idx}
                      className={`simulator-btn ${choice.color || 'primary'}`}
                      onClick={() => handleChoice(choice.next, choice)}
                      style={{ minHeight: '64px', padding: '12px 20px', width: '100%' }}
                    >
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div style={{ background: 'rgba(255,255,255,0.25)', width: '34px', height: '34px', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                          {choice.color === 'danger' ? <AlertCircle size={18} /> : <CheckCircle size={18} />}
                        </div>
                        <div style={{ textAlign: 'left' }}>
                          <div style={{ fontSize: '15.5px', fontWeight: 700, letterSpacing: '-0.01em' }}>{t(choice.label || choice.text)}</div>
                        </div>
                      </div>
                      <ChevronRight size={18} strokeWidth={3} />
                    </button>
                  ))}
                </div>
              </div>

            </div>
          )}
        </div>
      </main>

      <div className="simulator-footer">
        <Footer />
      </div>
    </div>
  );
};

export default ACLSWorkflow;
