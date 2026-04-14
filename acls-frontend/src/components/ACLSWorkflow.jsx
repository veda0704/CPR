import React, { useState, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate, useParams } from 'react-router-dom';
import LoadingSpinner from './LoadingSpinner';
import { getStep } from '../services/api';
import { ArrowLeft, Home, CheckCircle, Star, Trophy, ArrowRight, Play, Pause, RotateCcw, AlertTriangle, Info, Volume2, VolumeX } from 'lucide-react';
import Footer from './Footer';
import AnimatedECG from './AnimatedECG';
import { getModuleStatus, setModuleStatus } from '../utils/moduleStatus';

// --- Confetti Particle Component ---
const colors = ['#fb923c', '#ea580c', '#fbbf24', '#34d399', '#60a5fa', '#a78bfa', '#f472b6'];
const particles = Array.from({ length: 60 }, (_, i) => ({
  id: i,
  color: colors[i % colors.length],
  left: `${Math.random() * 100}%`,
  delay: `${Math.random() * 1.5}s`,
  duration: `${2.5 + Math.random() * 2}s`,
  size: `${6 + Math.random() * 8}px`,
  shape: Math.random() > 0.5 ? 'circle' : 'square',
  rotation: `${Math.random() * 360}deg`,
}));

const Confetti = () => {
  return (
    <div className="confetti-container" aria-hidden="true">
      {particles.map(p => (
        <div
          key={p.id}
          className="confetti-particle"
          style={{
            left: p.left,
            animationDelay: p.delay,
            animationDuration: p.duration,
            width: p.size,
            height: p.size,
            background: p.color,
            borderRadius: p.shape === 'circle' ? '50%' : '2px',
            transform: `rotate(${p.rotation})`,
          }}
        />
      ))}
    </div>
  );
};

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
    }
  };

  const t = map[lang] || map.en;
  const lower = (stepTitle || '').toLowerCase();

  if (lower.includes('bls') || lower.includes('responsiveness') || lower.includes('cpr') || lower.includes('pulse')) return t.bls;
  if (lower.includes('airway') || lower.includes('breathing') || lower.includes('choking') || lower.includes('lma') || lower.includes('rsi')) return t.airway;
  if (lower.includes('cardiac') || lower.includes('tachycard') || lower.includes('bradycard') || lower.includes('vf') || lower.includes('vt') || lower.includes('shock') || lower.includes('rhythm') || lower.includes('rosc')) return t.cardiac;
  if (lower.includes('stroke')) return t.stroke;
  if (lower.includes('acs') || lower.includes('mona') || lower.includes('coronary')) return t.acs;
  if (lower.includes('ecg') || lower.includes('wave') || lower.includes('paper')) return t.ecg;
  if (lower.includes('trauma')) return t.trauma;
  if (lower.includes('nls') || lower.includes('neonatal') || lower.includes('baby') || lower.includes('placental') || lower.includes('golden minute')) return t.nls;
  if (lower.includes('poison') || lower.includes('snake') || lower.includes('toxin') || lower.includes('naloxone') || lower.includes('atropine')) return t.poison;
  if (lower.includes('disaster') || lower.includes('triage') || lower.includes('preparation') || lower.includes('command')) return t.disaster;
  if (lower.includes('5h') || lower.includes('5t') || lower.includes('hypovolemia') || lower.includes('hypothermia') || lower.includes('thrombosis')) return t.h5t5;

  return t.default;
};

// --- Choice Cards Component (Generic Selector) ---
const ChoiceCards = ({ options, onSelect, lang, footerNote }) => {
  return (
    <div className="choice-cards-container">
      <div className="choice-cards-grid">
        {options.map((opt, idx) => (
          <div key={idx} className={`choice-card theme-${opt.theme || 'orange'}`}>
            <div className="choice-card-header">
              <div className="choice-card-image-box">
                <img src={opt.image} alt={opt.label} />
                {opt.badge && (
                  <div className="choice-card-badge">
                    {opt.badge === 'check' ? <CheckCircle size={20} color="#fff" strokeWidth={3} /> : <AlertTriangle size={20} color="#fff" strokeWidth={3} />}
                  </div>
                )}
              </div>
            </div>

            <div className="choice-card-body">
              <h2 className="choice-card-title">{opt.label}</h2>
              <p className="choice-card-desc">{opt.description}</p>

              {opt.notice && (
                <div className="choice-card-notice">
                  <div className="notice-icon"><Info size={16} /></div>
                  <p>{opt.notice}</p>
                </div>
              )}
            </div>

            <button className="btn choice-card-btn" onClick={() => onSelect(opt.next, opt)}>
              {opt.action_label || `SELECT ${opt.label}`}
              <ArrowRight size={18} />
            </button>
          </div>
        ))}
      </div>

      {footerNote && (
        <div className="choice-cards-footer-note">
          <div className="footer-note-icon"><AlertTriangle size={18} color="#f59e0b" /></div>
          <p>{footerNote}</p>
        </div>
      )}
    </div>
  );
};

// --- Main Component ---
const ACLSWorkflow = () => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const { '*': stepId } = useParams();
  const [stepData, setStepData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showCompletion, setShowCompletion] = useState(false);
  const [completionInfo, setCompletionInfo] = useState(null);
  const [isPlaying, setIsPlaying] = useState(true);
  const [voiceEnabled, setVoiceEnabled] = useState(localStorage.getItem('voiceEnabled') === 'true');
  const voiceEnabledRef = useRef(voiceEnabled);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const audioRef = useRef(null);
  const videoRef = useRef(null);
  const completionRef = useRef(null);
  const isMounted = useRef(true);

  useEffect(() => {
    isMounted.current = true;
    const fetchStep = async () => {
      setLoading(true);
      try {
        const res = await getStep(stepId);
        if (isMounted.current) setStepData(res.data);
      } catch {
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
    if (normalId === '1') return 'acls';
    if (normalId.startsWith('scene_safety')) return 'scene_safety';
    if (normalId.startsWith('abcde')) return 'abcde';
    if (normalId.startsWith('bls')) return 'bls';
    if (normalId.startsWith('choking')) return 'choking';
    if (normalId.startsWith('airway')) return 'airway';
    if (normalId.startsWith('adv_airway')) return 'adv_airway';
    if (normalId.startsWith('trauma')) return 'trauma';
    if (normalId.startsWith('poisoning')) return 'poisoning';
    if (normalId.startsWith('snake_bite')) return 'snake_bite';
    if (normalId.startsWith('stroke')) return 'stroke';
    if (normalId.startsWith('disaster')) return 'disaster';
    if (normalId.startsWith('delivery')) return 'delivery';
    if (normalId.startsWith('ecg')) return 'ecg';
    if (normalId.startsWith('rhythms')) return 'rhythms';
    if (normalId.startsWith('cardiac_alg')) return 'cardiac_alg';
    if (normalId.startsWith('h5t5')) return 'h5t5';
    return Object.keys(moduleMap).find((moduleKey) => normalId.includes(moduleKey)) || null;
  };

  const stopAudio = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
      setIsSpeaking(false);
    }
  };

  const handlePlayVoice = React.useCallback(async () => {
    stopAudio();
    if (!voiceEnabledRef.current || !isMounted.current || !stepData?.audio_url) return;

    try {
      const audioUrl = stepData.audio_url;
      const audio = new Audio(audioUrl);

      // Double check before assignment
      if (!isMounted.current) return;

      audioRef.current = audio;
      setIsSpeaking(true);
      audio.play();
      audio.onended = () => {
        if (isMounted.current) setIsSpeaking(false);
      };
    } catch (err) {
      if (isMounted.current) {
        console.error('Speech error:', err);
        setIsSpeaking(false);
      }
    }
  }, [stepData?.audio_url]);

  useEffect(() => {
    if (stepData) {
      const moduleId = getModuleIdFromStep(stepData.id || stepId);
      if (moduleId && getModuleStatus(moduleId) !== 'completed') {
        setModuleStatus(moduleId, 'in_progress');
      }
    }
    if (stepData && voiceEnabled) {
      handlePlayVoice();
    }
    return () => stopAudio();
  }, [stepData, voiceEnabled, handlePlayVoice, getModuleIdFromStep, stepId]);

  // Audio Playback effect removed for manual trigger only

  const handleChoice = (nextStep, choice) => {
    stopAudio();
    if (nextStep === 'dashboard') {
      if (choice?.isExit) {
        navigate('/dashboard');
        return;
      }
      const moduleId = getModuleIdFromStep(stepData?.id || stepId);
      if (moduleId) setModuleStatus(moduleId, 'completed');
      const info = getCompletionContent(stepData?.title, i18n.language);
      setCompletionInfo(info);
      setShowCompletion(true);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else {
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

  // --- Completion Overlay ---
  if (showCompletion && completionInfo) {
    return (
      <div className="completion-overlay" ref={completionRef}>
        <Confetti />
        <div className="completion-card">
          <div className="completion-emoji-ring">
            <span className="completion-emoji">{completionInfo.emoji}</span>
          </div>
          <div className="completion-stars">
            {[0, 1, 2].map(i => (
              <Star
                key={i}
                size={28}
                fill="#fbbf24"
                color="#fbbf24"
                style={{ animationDelay: `${i * 0.15}s` }}
                className="completion-star-icon"
              />
            ))}
          </div>
          <h1 className="completion-headline">{completionInfo.headline}</h1>
          <p className="completion-sub">{completionInfo.sub}</p>
          <div className="completion-module-badge">
            <CheckCircle size={16} style={{ color: '#16a34a' }} />
            <span>{t(stepData.title)}</span>
          </div>
          <div className="completion-actions">
            <button className="btn completion-btn-primary" onClick={handleGoToDashboard}>
              <Home size={18} />
              Back to Dashboard
            </button>
          </div>
        </div>
      </div>
    );
  }

  // --- Normal Step View ---
  return (
    <div className="app-container" style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', background: 'var(--bg)' }}>
      <header className="acls-header" style={{ marginBottom: '24px' }}>
        <div className="progress-bar-flow"></div>
        <div className="header-left">
          <button className="icon-btn" onClick={() => { stopAudio(); navigate(-1); }} title={t('back')}><ArrowLeft size={18} /></button>
          <button className="icon-btn" onClick={() => { stopAudio(); navigate('/dashboard'); }} title={t('home')}><Home size={18} /></button>
        </div>
        <div className="header-center" style={{ fontWeight: 700 }}>
          {t(stepData.title)}
        </div>
        <div className="header-right">
          <div className="language-selector" style={{ background: 'rgba(255,255,255,0.4)', padding: '4px', borderRadius: '12px', border: '1px solid rgba(0,0,0,0.05)', display: 'flex', gap: '4px' }}>
              <button 
                onClick={() => { i18n.changeLanguage('en'); localStorage.setItem('i18nextLng', 'en'); }} 
                className={i18n.language === 'en' ? 'active' : ''}
                style={{ 
                  background: i18n.language === 'en' ? 'var(--orange)' : 'transparent',
                  color: i18n.language === 'en' ? 'white' : 'var(--muted)',
                  border: 'none',
                  padding: '4px 10px',
                  borderRadius: '8px',
                  fontSize: '11px',
                  fontWeight: 800,
                  cursor: 'pointer',
                  transition: 'all 0.2s'
                }}
              >
                EN
              </button>
              <button 
                onClick={() => { i18n.changeLanguage('te'); localStorage.setItem('i18nextLng', 'te'); }} 
                className={i18n.language === 'te' ? 'active' : ''}
                style={{ 
                  background: i18n.language === 'te' ? 'var(--orange)' : 'transparent',
                  color: i18n.language === 'te' ? 'white' : 'var(--muted)',
                  border: 'none',
                  padding: '4px 10px',
                  borderRadius: '8px',
                  fontSize: '11px',
                  fontWeight: 800,
                  cursor: 'pointer',
                  transition: 'all 0.2s'
                }}
              >
                TE
              </button>
          </div>
        </div>
      </header>

      <main key={stepData.id} className="guided-step animate-step" style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', width: '100%' }}>
        <div className={`acls-workflow-layout ${stepData.video || stepData.interactive_component ? 'has-media' : 'no-media'} ${stepData.interactive_component === 'choice_cards' || stepData.interactive_component === 'patient_type_selector' ? 'is-selector-layout' : ''}`}>
          {(stepData.video || stepData.interactive_component) && (
            <div className={`acls-media-container ${stepData.interactive_component === 'choice_cards' || stepData.interactive_component === 'patient_type_selector' ? 'is-selector-media' : ''}`} style={{ background: stepData.interactive_component ? 'transparent' : '#000', border: stepData.interactive_component ? 'none' : '2px solid white', boxShadow: stepData.interactive_component ? 'none' : 'var(--shadow-sm)' }}>
              {stepData.interactive_component === 'ecg_monitor' ? (
                <AnimatedECG rhythms={stepData.interactive_props?.rhythms || ['nsr']} />
              ) : stepData.interactive_component === 'patient_type_selector' || stepData.interactive_component === 'choice_cards' ? (
                <ChoiceCards
                  options={stepData.interactive_props?.options || []}
                  onSelect={handleChoice}
                  lang={i18n.language}
                  footerNote={stepData.interactive_props?.footer_note}
                />
              ) : stepData.video && stepData.video.match(/\.(jpeg|jpg|gif|png|webp|svg)$/i) ? (
                <img src={stepData.video} alt={t(stepData.title)} style={{ width: '100%', height: '100%', objectFit: 'contain', background: 'white' }} />
              ) : stepData.video ? (
                <div className="video-container-wrapper">
                  <video
                    ref={videoRef}
                    src={stepData.video}
                    className="acls-video"
                    autoPlay
                    loop
                    muted
                    playsInline
                    onPlay={() => setIsPlaying(true)}
                    onPause={() => setIsPlaying(false)}
                  />
                  <div className="video-controls-bar">
                    <button
                      onClick={() => isPlaying ? videoRef.current.pause() : videoRef.current.play()}
                      className="video-control-btn"
                      title={isPlaying ? 'Pause' : 'Play'}
                    >
                      {isPlaying ? <Pause size={18} fill="currentColor" /> : <Play size={18} fill="currentColor" />}
                    </button>
                    <div className="video-control-divider" />
                    <button
                      onClick={() => {
                        videoRef.current.currentTime = 0;
                        videoRef.current.play();
                      }}
                      className="video-control-btn"
                      title="Replay"
                    >
                      <RotateCcw size={16} />
                    </button>
                  </div>
                </div>
              ) : null}
            </div>
          )}

          {(stepData.question || (stepData.choices && stepData.choices.length > 0)) && (
            <div className="acls-card--sim" style={{ position: 'relative' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '16px', marginBottom: (stepData.choices && stepData.choices.length > 0) ? '32px' : '0' }}>
                <h2 style={{ fontSize: '22px', fontWeight: 600, textAlign: 'left', whiteSpace: 'pre-line', lineHeight: '1.4', margin: 0, flex: 1 }}>
                  {t(stepData.question)}
                </h2>
                <button
                  className={`icon-btn voice-toggle-card ${voiceEnabled ? 'active' : ''} ${isSpeaking ? 'speaking' : ''}`}
                  onClick={toggleVoice}
                  title={t('toggle_voice')}
                  style={{ marginTop: '2px' }}
                >
                  {voiceEnabled ? <Volume2 size={22} /> : <VolumeX size={22} />}
                  {isSpeaking && <div className="speaking-wave" />}
                </button>
              </div>
              <div className="stack" style={{ gap: '12px' }}>
                {stepData.choices.map((choice, idx) => (
                  <button
                    key={idx}
                    className={`btn btn--${choice.color || 'primary'}`}
                    onClick={() => handleChoice(choice.next, choice)}
                    style={{ width: '100%', height: '50px', fontSize: '17px', borderRadius: '12px' }}
                  >
                    {t(choice.label)}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      </main>

      <Footer />
    </div>
  );
};

export default ACLSWorkflow;
