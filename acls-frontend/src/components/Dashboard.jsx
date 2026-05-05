import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { getDashboard, logout } from '../services/api';
import {
  LogOut, Play, Zap, Heart, Activity, Thermometer, ClipboardList, Wind,
  AlertTriangle, Monitor, HeartPulse, Brain, Baby, ShieldAlert, Siren,
  ListChecks, Search, ChevronRight, CheckCircle2, Moon, Sun, User, Clock, Trophy, RotateCcw
} from 'lucide-react';
import Footer from './Footer';
import iaclsLogo from '../assets/iacls-logo.png';
import bavyaLogo from '../assets/bavya-logo.png';
import { getModuleStatus, setModuleStatus, getModuleProgress } from '../utils/moduleStatus';
import SettingsPanel from './SettingsPanel';
import { Settings } from 'lucide-react';

const Skeleton = ({ className }) => <div className={`skeleton ${className}`} />;

const Dashboard = ({ user, setUser, theme, toggleTheme }) => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const [levels, setLevels] = useState([]);
  const [moduleStatusMap, setModuleStatusMap] = useState({});
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  const getModuleIcon = (modId) => {
    const mapping = {
      scene_safety: ShieldAlert,
      abcde: ClipboardList,
      bls: HeartPulse,
      choking: AlertTriangle,
      airway: Wind,
      adv_airway: Activity,
      trauma: Siren,
      poisoning: Thermometer,
      snake_bite: ShieldAlert,
      stroke: Brain,
      disaster: ListChecks,
      intro: Monitor,
      delivery: Baby,
      ecg: Monitor,
      rhythms: Activity,
      cardiac_alg: Zap,
      h5t5: CheckCircle2,
      acls: Play,
      ecg_rhythms: Monitor,
    };
    return mapping[modId] || Monitor;
  };

  const moduleSubtitles = {
    intro: 'description_acls',
    scene_safety: 'description_scene_safety',
    abcde: 'description_abcde',
    bls: 'description_bls',
    choking: 'description_choking',
    airway: 'description_airway',
    adv_airway: 'description_adv_airway',
    ecg: 'description_ecg_rhythms',
    ecg_rhythms: 'description_ecg_rhythms',
    cardiac_alg: 'description_cardiac_alg',
    stroke: 'description_stroke',
    delivery: 'description_delivery',
    poisoning: 'description_poisoning',
    snake_bite: 'description_snake_bite',
    disaster: 'description_disaster',
    trauma: 'description_trauma',
    h5t5: 'description_h5t5',
    acls: 'description_acls',
  };

  const getModuleImage = (modId) => {
    const mapping = {
      scene_safety: 'scenesafetym1.png',
      abcde: 'abcdem2.png',
      bls: 'blscprm3.png',
      choking: 'chokingm4.png',
      airway: 'airwayanatomy.png',
      adv_airway: 'advancedairway.png',
      trauma: 'trauma.png',
      poisoning: 'poisionmanagement.png',
      snake_bite: 'snakebite.png',
      stroke: 'strokemanagement.png',
      disaster: 'diastermanagement.png',
      intro: 'abcdem2.png',
      ecg: 'ecgm13.png',
      rhythms: 'advancedairway.png',
      cardiac_alg: 'blscprm3.png',
      h5t5: 'scenesafetym1.png',
      acls: 'abcdem2.png',
      ecg_rhythms: 'ecgm13.png'
    };
    const filename = mapping[modId] || 'abcdem2.png';
    return `http://10.2.1.15:8002/static/images/module-bgs/${filename}`;
  };

  useEffect(() => {
    const fetchDashboard = async () => {
      try {
        setLoading(true);
        const res = await getDashboard();
        const levelsData = res.data.levels || [];
        setLevels(levelsData);
        const statusMap = {};
        levelsData.forEach((level) => {
          level.modules.forEach((mod) => {
            statusMap[mod.id] = getModuleStatus(mod.id, user?.email);
          });
        });
        setModuleStatusMap(statusMap);
        setError(null);
      } catch (err) {
        console.error(err);
        setError(t('api_error') || 'Failed to load dashboard data. Please try again.');
        toast.error(t('api_error') || 'Server connection failed');
      } finally {
        setLoading(false);
      }
    };
    fetchDashboard();
  }, [i18n.language, user?.email]);

  const handleLogout = async () => {
    try {
      await logout();
    } catch (err) {
      console.error('Logout API call failed', err);
    } finally {
      sessionStorage.removeItem('access_token');
      localStorage.removeItem('access_token');
      setUser(null);
      toast.success(t('logout_success'), { icon: '👋' });
      navigate('/login');
    }
  };

  const handleModuleClick = (mod) => {
    if (moduleStatusMap[mod.id] === 'locked') {
      toast.error(t('module_locked'));
      return;
    }
    if (moduleStatusMap[mod.id] !== 'completed') {
      setModuleStatus(mod.id, 'in_progress', user?.email);
      setModuleStatusMap((prev) => ({ ...prev, [mod.id]: 'in_progress' }));
    }
    navigate(`/acls/${mod.start_step}`);
  };

  const calculateLevelProgress = (modules) => {
    if (!modules || modules.length === 0) return 0;
    const completed = modules.filter(m => moduleStatusMap[m.id] === 'completed').length;
    return Math.round((completed / modules.length) * 100);
  };

  const getStatusDisplay = (status) => {
    switch (status) {
      case 'completed': return { icon: <CheckCircle2 size={14} />, label: t('completed') || 'Completed', class: 'completed' };
      case 'in_progress': return { icon: <Activity size={14} />, label: t('in_progress') || 'In Progress', class: 'in_progress' };
      default: return { icon: <ShieldAlert size={14} />, label: t('locked') || 'Locked', class: 'locked' };
    }
  };

  if (loading) {
    return (
      <div className="medical-bg" style={{ minHeight: '100vh' }}>
        <nav className="floating-nav"><Skeleton className="nav-skeleton" /></nav>
        <main className="app-container dashboard-main">
          <Skeleton className="hero-skeleton" />
          <div className="module-grid">
            {[1, 2, 3].map(i => <Skeleton key={i} className="card-skeleton" />)}
          </div>
        </main>
      </div>
    );
  }

  if (error) {
    return (
      <div className="medical-bg" style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <div className="glass-card animate-reveal" style={{ padding: '40px', textAlign: 'center', maxWidth: '400px' }}>
          <AlertTriangle size={64} color="var(--danger)" style={{ marginBottom: '24px', filter: 'drop-shadow(0 0 10px rgba(239, 68, 68, 0.2))' }} />
          <h2 style={{ fontSize: '24px', fontWeight: 800, marginBottom: '12px', color: 'var(--text-main)' }}>
            {t('api_error') || 'Server Connection Failed'}
          </h2>
          <p style={{ color: 'var(--text-muted)', marginBottom: '32px', lineHeight: 1.6 }}>
            We couldn't reach the medical database. Please check your network or try again.
          </p>
          <button 
            className="lms-button-refined" 
            onClick={() => window.location.reload()}
            style={{ margin: '0 auto', width: '100%', justifyContent: 'center', height: '54px' }}
          >
            <RotateCcw size={18} />
            <span>{t('retry') || 'Retry Connection'}</span>
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="medical-bg">
      <nav className="floating-nav animate-reveal">
        <div style={{ display: 'flex', alignItems: 'center', gap: '24px', flex: 1 }}>
          <img 
            src={iaclsLogo} 
            alt="IACLS Logo" 
            style={{ 
              height: '75px', 
              objectFit: 'contain', 
              filter: 'brightness(0) invert(1) drop-shadow(0 0 0.5px white)' 
            }} 
          />
          <div className="search-container nav-search" style={{ flex: 1, maxWidth: '600px' }}>
            <Search size={18} />
            <input
              type="text"
              placeholder={t('search_modules') || "Search modules..."}
              className="search-input"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <div className="user-nav-block" style={{ borderLeft: 'none' }}>
            <div className="user-info">
              <span className="user-name" style={{ color: 'white' }}>{user?.first_name || t('clinical_user')}</span>
              <span className="user-role" style={{ color: 'rgba(255,255,255,0.7)', fontSize: '0.72rem' }}>{user?.role || 'Clinician'}</span>
            </div>
            <div className="user-avatar" style={{ background: 'rgba(255,255,255,0.2)', color: 'white' }}>
              <User size={20} />
            </div>
            
            <button 
              className="icon-btn" 
              onClick={() => setIsSettingsOpen(true)}
              title={t('settings')}
              style={{ background: 'rgba(255,255,255,0.15)', color: 'white', border: '1px solid rgba(255,255,255,0.3)', width: '42px', height: '42px', borderRadius: '14px' }}
            >
              <Settings size={20} />
            </button>

            <button 
              onClick={handleLogout} 
              className="logout-btn"
              style={{ 
                background: 'rgba(255,255,255,0.15)', 
                width: '42px', 
                height: '42px', 
                borderRadius: '14px', 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center',
                color: 'white',
                border: '1px solid rgba(255,255,255,0.3)',
                cursor: 'pointer'
              }}
            >
              <LogOut size={20} />
            </button>
          </div>
        </div>
      </nav>

      <SettingsPanel 
        isOpen={isSettingsOpen} 
        onClose={() => setIsSettingsOpen(false)} 
        theme={theme} 
        toggleTheme={toggleTheme} 
      />

      <main className="app-container dashboard-main">
        {levels.map((level) => {
          const progress = calculateLevelProgress(level.modules);
          const activeMod = level.modules.find(m => moduleStatusMap[m.id] === 'in_progress') || level.modules[0];
          const nextStep = level.modules.find(m => moduleStatusMap[m.id] === 'locked' || moduleStatusMap[m.id] === undefined) || level.modules[0];
          const lastAccessed = level.modules.find(m => moduleStatusMap[m.id] !== 'locked') || level.modules[0];
          
          const filteredModules = level.modules.filter(m => 
            t(m.name).toLowerCase().includes(searchQuery.toLowerCase())
          );

          if (searchQuery && filteredModules.length === 0) return null;

          return (
            <div key={level.id} className="animate-reveal dashboard-section">
              <section className="dashboard-hero compact-hero-row">
                <div className="hero-row-content">
                  <div className="hero-visual-section">
                    <div className="hero-tag-circle-mini">
                      <div className="hero-progress-text" style={{ position: 'relative', top: 'auto', left: 'auto', transform: 'none' }}>
                        <Trophy size={32} color="var(--primary)" strokeWidth={2.5} />
                      </div>
                    </div>
                  </div>

                  <div className="hero-text-section">
                    <span className="hero-subheading">{t('learning_journey')}</span>
                    <h2 className="hero-heading">{t(level.name)}</h2>
                    <p className="hero-description">{t(level.description || moduleSubtitles[level.modules[0]?.id])}</p>
                  </div>

                  <div className="hero-cards-section">
                    <div className="hero-stat-pill" onClick={() => handleModuleClick(activeMod)} style={{ cursor: 'pointer' }}>
                      <div className="pill-icon-box"><Activity size={16} /></div>
                      <div className="pill-content">
                        <span className="pill-label">{t('active_module')}</span>
                        <span className="pill-value">{t(activeMod.name)}</span>
                        <span className="pill-status"><span className="status-dot"></span> {t('in_progress')}</span>
                      </div>
                    </div>

                    <div className="hero-stat-pill" onClick={() => handleModuleClick(nextStep)} style={{ cursor: 'pointer' }}>
                      <div className="pill-icon-box"><Zap size={16} /></div>
                      <div className="pill-content">
                        <span className="pill-label">{t('next_step')}</span>
                        <span className="pill-value">{t(nextStep.name)}</span>
                        <span className="pill-link">{t('continue_learning')} →</span>
                      </div>
                    </div>

                    <div className="hero-stat-pill" onClick={() => handleModuleClick(lastAccessed)} style={{ cursor: 'pointer' }}>
                      <div className="pill-icon-box"><Clock size={16} /></div>
                      <div className="pill-content">
                        <span className="pill-label">{t('last_accessed')}</span>
                        <span className="pill-value">{t(lastAccessed.name)}</span>
                        <span className="pill-time">{t('today_time')}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </section>

              <div className="module-grid">
                {filteredModules.map((mod, idx) => {
                  const status = getStatusDisplay(moduleStatusMap[mod.id]);
                  const modProgress = getModuleProgress(mod.id, user?.email);
                  
                  return (
                    <div key={mod.id} className={`lms-module-card animate-reveal ${moduleStatusMap[mod.id] === 'locked' ? 'card-locked' : ''}`} 
                         onClick={() => handleModuleClick(mod)} 
                         style={{ animationDelay: `${idx * 0.1}s` }}>
                      <div className="card-thumbnail">
                        <div className={`module-status-pill ${status.class}`}>
                          {status.icon} {status.label}
                        </div>
                        <img src={getModuleImage(mod.id)} alt={mod.name} className="module-card-img" />
                        {moduleStatusMap[mod.id] === 'locked' && (
                          <div className="lock-overlay"><ShieldAlert size={48} /></div>
                        )}
                      </div>

                      <div className="card-body">
                        <div className="card-title-row">
                          <div style={{ flex: 1 }}>
                            <h3 className="card-title">{t(mod.name)}</h3>
                            <p className="card-description">{t(moduleSubtitles[mod.id] || '')}</p>
                          </div>
                        </div>

                        <div className="module-footer">
                          <button className="lms-button-refined">
                            <span>{moduleStatusMap[mod.id] === 'completed' ? t('Review') : (moduleStatusMap[mod.id] === 'in_progress' ? t('Continue') : t('Start'))}</span>
                            <ChevronRight size={18} />
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </main>
      <Footer />
    </div>
  );
};

export default Dashboard;
