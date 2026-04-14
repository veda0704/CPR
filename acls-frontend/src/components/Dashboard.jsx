import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { getDashboard } from '../services/api';
import { LogOut, Play, Zap, Heart, Activity, Thermometer, ClipboardList, Wind, AlertTriangle, Monitor, HeartPulse, Brain, Baby, ShieldAlert, Siren, ListChecks } from 'lucide-react';
import Footer from './Footer';
import iaclsLogo from '../assets/iacls-logo.png';
import { getModuleStatus, setModuleStatus, getStatusLabel, getStatusColor } from '../utils/moduleStatus';

const Dashboard = ({ user, setUser }) => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const [levels, setLevels] = useState([]);
  const [moduleStatusMap, setModuleStatusMap] = useState({});

  const moduleIcons = {
    scene_safety: <ShieldAlert size={24} />,
    abcde: <ClipboardList size={24} />,
    bls: <HeartPulse size={24} />,
    airway: <Wind size={24} />,
    adv_airway: <Thermometer size={24} />,
    choking: <AlertTriangle size={24} />,
    ecg: <Monitor size={24} />,
    rhythms: <Activity size={24} />,
    cardiac_alg: <Zap size={24} />,
    stroke: <Brain size={24} />,
    delivery: <Baby size={24} />,
    poisoning: <ShieldAlert size={24} />,
    snake_bite: <AlertTriangle size={24} />,
    disaster: <Siren size={24} />,
    h5t5: <ListChecks size={24} />,
    acls: <Heart size={24} />,
  };


  useEffect(() => {
    const fetchDashboard = async () => {
      try {
        const res = await getDashboard();
        const levelsData = res.data.levels || [];
        setLevels(levelsData);
        const statusMap = {};
        levelsData.forEach((level) => {
          level.modules.forEach((mod) => {
            statusMap[mod.id] = getModuleStatus(mod.id);
          });
        });
        setModuleStatusMap(statusMap);
      } catch (err) {
        console.error(err);
      }
    };
    fetchDashboard();
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    setUser(null);
    navigate('/login');
  };


  const handleModuleClick = (mod) => {
    setModuleStatus(mod.id, 'in_progress');
    setModuleStatusMap((prev) => ({ ...prev, [mod.id]: 'in_progress' }));
    navigate(`/acls/${mod.start_step}`);
  };

  return (
    <div className="app-container" style={{ minHeight: '100%', display: 'flex', flexDirection: 'column', background: 'transparent' }}>
      <header className="site-header" style={{ width: 'calc(100% - 48px)', margin: '24px auto 48px auto', backdropFilter: 'blur(20px)', background: 'rgba(255, 255, 255, 0.4)', border: '1px solid rgba(255,255,255,0.6)', borderRadius: '24px', boxShadow: '0 12px 24px rgba(154, 52, 18, 0.08)' }}>
        <div style={{ padding: '12px 32px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div className="brand" style={{ display: 'flex', alignItems: 'center' }}>
            <img src={iaclsLogo} alt="iACLS Logo" style={{ height: '85px', objectFit: 'contain', mixBlendMode: 'multiply' }} />
          </div>

          <div className="nav" style={{ gap: '24px', display: 'flex', alignItems: 'center' }}>
            <div className="language-selector" style={{ background: 'rgba(255,255,255,0.4)', padding: '4px', borderRadius: '12px', border: '1px solid rgba(0,0,0,0.05)' }}>
              <button 
                onClick={() => { i18n.changeLanguage('en'); localStorage.setItem('i18nextLng', 'en'); }} 
                className={i18n.language === 'en' ? 'active' : ''}
                style={{ 
                  background: i18n.language === 'en' ? 'var(--orange)' : 'transparent',
                  color: i18n.language === 'en' ? 'white' : 'var(--muted)',
                  border: 'none',
                  padding: '6px 14px',
                  borderRadius: '10px',
                  fontSize: '13px',
                  fontWeight: 800,
                  cursor: 'pointer',
                  transition: 'all 0.2s'
                }}
              >
                ENGLISH
              </button>
              <button 
                onClick={() => { i18n.changeLanguage('te'); localStorage.setItem('i18nextLng', 'te'); }} 
                className={i18n.language === 'te' ? 'active' : ''}
                style={{ 
                  background: i18n.language === 'te' ? 'var(--orange)' : 'transparent',
                  color: i18n.language === 'te' ? 'white' : 'var(--muted)',
                  border: 'none',
                  padding: '6px 14px',
                  borderRadius: '10px',
                  fontSize: '13px',
                  fontWeight: 800,
                  cursor: 'pointer',
                  transition: 'all 0.2s'
                }}
              >
                తెలుగు
              </button>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '16px', borderLeft: '2px solid rgba(154, 52, 18, 0.1)', paddingLeft: '24px', height: '40px' }}>
              <div style={{ textAlign: 'right', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                {user && (user.first_name || user.username) && (
                  <div style={{ fontSize: '15px', fontWeight: 800, color: '#9a3412', lineHeight: '1.2' }}>{user.first_name || user.username}</div>
                )}
              </div>
              <button onClick={handleLogout} style={{ background: '#9a3412', border: 'none', width: '40px', height: '40px', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', boxShadow: '0 4px 10px rgba(154, 52, 18, 0.2)', transition: 'transform 0.2s' }} onMouseOver={(e) => e.currentTarget.style.transform = 'scale(1.05)'} onMouseOut={(e) => e.currentTarget.style.transform = 'scale(1)'}>
                <LogOut size={18} color="#ffffff" style={{ marginLeft: '4px' }} />
              </button>
            </div>
          </div>
        </div>
      </header>

      <main style={{ flex: 1 }}>
        <section style={{ marginBottom: '64px', padding: '0 24px' }}>

          {levels.map((level, lIdx) => (
            <div key={level.id} style={{ marginBottom: '56px' }}>
              {/* Level Section Header */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '24px' }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '4px' }}>
                    <h2 style={{ fontSize: '26px', fontWeight: 900, margin: 0, color: 'var(--text)' }}>{level.name}</h2>
                    {lIdx === 0 && (
                      <span style={{ background: 'var(--orange)', color: 'white', fontSize: '11px', fontWeight: 900, padding: '4px 12px', borderRadius: '20px', letterSpacing: '1px', textTransform: 'uppercase' }}>
                        {level.tag}
                      </span>
                    )}
                    {lIdx > 0 && (
                      <span style={{ background: 'rgba(0,0,0,0.06)', color: 'var(--muted)', fontSize: '11px', fontWeight: 800, padding: '4px 12px', borderRadius: '20px', letterSpacing: '1px', textTransform: 'uppercase' }}>
                        {level.tag}
                      </span>
                    )}
                  </div>
                  <p style={{ margin: 0, color: 'var(--muted)', fontSize: '15px' }}>{level.description}</p>
                </div>
              </div>

              {/* Module Cards Grid */}
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '24px' }}>
                {level.modules.map((mod, idx) => (
                  <div
                    key={mod.id}
                    className={`card stagger-${(idx % 4) + 1}`}
                    onClick={() => handleModuleClick(mod)}
                    style={{
                      padding: '40px',
                      cursor: 'pointer',
                      position: 'relative',
                      overflow: 'hidden',
                      display: 'flex',
                      flexDirection: 'column',
                      gap: '24px',
                    }}
                    onMouseOver={(e) => {
                      e.currentTarget.style.transform = 'translateY(-10px)';
                      e.currentTarget.style.boxShadow = 'var(--shadow-lg)';
                      e.currentTarget.style.borderColor = 'var(--orange)';
                    }}
                    onMouseOut={(e) => {
                      e.currentTarget.style.transform = 'translateY(0)';
                      e.currentTarget.style.boxShadow = 'var(--shadow-sm)';
                      e.currentTarget.style.borderColor = 'rgba(255,255,255,0.5)';
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                      <div style={{ background: lIdx === 0 ? 'var(--accent-gradient)' : 'rgba(0,0,0,0.05)', padding: '16px', borderRadius: '18px', color: lIdx === 0 ? 'white' : 'var(--orange)' }}>
                        {moduleIcons[mod.id] || <Activity size={24} />}
                      </div>
                      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '8px' }}>
                        <div style={{ fontSize: '12px', fontWeight: 800, color: 'var(--orange)', textTransform: 'uppercase', letterSpacing: '1px' }}>{t('module_prefix')} 0{idx + 1}</div>
                      </div>
                    </div>

                    <div>
                      <h3 style={{ fontSize: '22px', fontWeight: 800, margin: '0 0 12px' }}>{t(mod.name)}</h3>
                      <p style={{ fontSize: '14px', lineHeight: 1.5, margin: '0 0 16px' }}>{t(mod.id + '_desc')}</p>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px', borderTop: '1px solid rgba(0,0,0,0.05)', paddingTop: '16px' }}>
                      <div style={{ background: `${getStatusColor(moduleStatusMap[mod.id])}15`, padding: '6px 12px', borderRadius: '16px', fontSize: '12px', fontWeight: 700, color: getStatusColor(moduleStatusMap[mod.id]) }}>
                        {getStatusLabel(moduleStatusMap[mod.id])}
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, fontSize: '13px', background: 'var(--orange)', color: 'white', padding: '6px 12px', borderRadius: '16px' }}>
                        {t('explore_protocol')} <Play size={14} fill="white" />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </section>

      </main>

      <Footer />
    </div>
  );
};

export default Dashboard;
