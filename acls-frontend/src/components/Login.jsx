import React, { useState } from 'react';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useNavigate, Link } from 'react-router-dom';
import { login } from '../services/api';
import { User, Lock } from 'lucide-react';
import Footer from './Footer';
import iaclsLogo from '../assets/iacls-logo.png';

const Login = ({ onLogin, theme, toggleTheme }) => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const toggleLanguage = (lang) => {
    i18n.changeLanguage(lang);
    localStorage.setItem('i18nextLng', lang);
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const res = await login(email, password);
      localStorage.setItem('access_token', res.data.tokens.access);
      localStorage.setItem('refresh_token', res.data.tokens.refresh);
      onLogin(res.data.user);
      toast.success(i18n.language === 'te' ? 'లాగిన్ విజయవంతమైంది!' : 'Login successful!', {
        style: {
          background: '#9a3412',
          color: '#fff',
          fontWeight: 'bold',
        }
      });
      navigate('/dashboard');
    } catch (err) {
      console.error(err);
      const errorMsg = t('invalid_credentials');
      setError(errorMsg);
      toast.error(errorMsg, {
        style: {
          background: '#ef4444',
          color: '#fff',
          fontWeight: 'bold'
        }
      });
    }
  };

  const rememberMeLabel = i18n.language === 'te' ? 'నన్ను గుర్తుంచుకోండి' : 'Remember me';
  const forgotPasswordLabel = i18n.language === 'te' ? 'పాస్‌వర్డ్ మర్చిపోయారా?' : 'Forgot Password?';

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100%', paddingBottom: '24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 32px', zIndex: 10 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <img src={iaclsLogo} alt="iACLS Logo" style={{ height: '100px', objectFit: 'contain', filter: 'var(--logo-filter)' }} />
        </div>
        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
          <button onClick={() => toggleLanguage('en')} style={{ background: i18n.language === 'en' ? 'var(--orange)' : 'var(--card)', color: i18n.language === 'en' ? '#fff' : 'var(--red)', border: 'none', padding: '6px 16px', borderRadius: '20px', fontWeight: 'bold', cursor: 'pointer', boxShadow: 'var(--shadow-sm)' }}>EN</button>
          <button onClick={() => toggleLanguage('te')} style={{ background: i18n.language === 'te' ? 'var(--orange)' : 'var(--card)', color: i18n.language === 'te' ? '#fff' : 'var(--red)', border: 'none', padding: '6px 16px', borderRadius: '20px', fontWeight: 'bold', cursor: 'pointer', boxShadow: 'var(--shadow-sm)' }}>తెలుగు</button>
          <button onClick={toggleTheme} className="theme-toggle-btn" title={theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode'} aria-label="Toggle theme">
            {theme === 'dark' ? '☀️' : '🌙'}
          </button>
        </div>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '8px', zIndex: 10 }}>
        <div style={{ position: 'relative', width: '100%', maxWidth: '500px', marginTop: '16px' }}>
          <div
            style={{
              background: 'var(--card)',
              backdropFilter: 'blur(20px)',
              WebkitBackdropFilter: 'blur(20px)',
              border: '1px solid var(--card-border)',
              borderRadius: '24px',
              padding: '56px 40px 24px 40px',
              boxShadow: 'var(--shadow-lg)',
              position: 'relative',
            }}
          >
            <div
              style={{
                position: 'absolute',
                top: '-55px',
                left: '50%',
                transform: 'translateX(-50%)',
                width: '110px',
                height: '110px',
                borderRadius: '50%',
                background: 'var(--red)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 16px 32px rgba(154, 52, 18, 0.4)',
                border: '6px solid var(--card-border)',
              }}
            >
              <User size={48} color="#ffffff" />
            </div>

            <form onSubmit={handleLogin} id="login-form" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div style={{ display: 'flex', height: '56px', overflow: 'hidden', borderRadius: '8px', boxShadow: 'var(--shadow-sm)' }}>
                <div style={{ width: '56px', background: 'var(--red)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <User size={22} color="#ffffff" />
                </div>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder={t('email')}
                  style={{ flex: 1, border: 'none', background: 'var(--input-bg)', padding: '0 16px', fontSize: '16px', color: 'var(--text)', outline: 'none' }}
                  required
                />
              </div>

              <div style={{ display: 'flex', height: '56px', overflow: 'hidden', borderRadius: '8px', boxShadow: 'var(--shadow-sm)' }}>
                <div style={{ width: '56px', background: 'var(--red)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <Lock size={22} color="#ffffff" />
                </div>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder={t('password')}
                  style={{ flex: 1, border: 'none', background: 'var(--input-bg)', padding: '0 16px', fontSize: '16px', color: 'var(--text)', outline: 'none' }}
                  required
                />
              </div>

              {error && <div style={{ color: '#ef4444', fontSize: '14px', fontWeight: 600, textAlign: 'center', marginTop: '-4px' }}>{error}</div>}

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '6px', fontSize: '15px', color: 'var(--text)', fontWeight: 600 }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                  <input type="checkbox" style={{ accentColor: 'var(--orange)', cursor: 'pointer', width: '18px', height: '18px', margin: 0 }} />
                  {rememberMeLabel}
                </label>
                <span style={{ cursor: 'pointer', fontStyle: 'italic', opacity: 0.8 }}>{forgotPasswordLabel}</span>
              </div>
            </form>

            <div style={{ textAlign: 'center', marginTop: '28px', paddingBottom: '16px' }}>
              <span style={{ fontSize: '15px', color: 'var(--red)', fontWeight: 500 }}>
                {t('dont_have_account')} <Link to="/signup" style={{ color: 'var(--orange)', fontWeight: 800, textDecoration: 'none' }}>{t('signup')}</Link>
              </span>
            </div>
          </div>

          <div style={{ position: 'relative', marginTop: '-28px', display: 'flex', justifyContent: 'center', zIndex: 12 }}>
            <button
              type="submit"
              form="login-form"
              style={{
                padding: '0',
                height: '56px',
                width: '280px',
                background: 'linear-gradient(135deg, #fb923c 0%, #ea580c 100%)',
                color: '#ffffff',
                border: 'none',
                borderRadius: '16px',
                fontSize: '17px',
                fontWeight: 800,
                letterSpacing: '1.5px',
                cursor: 'pointer',
                boxShadow: '0 8px 24px rgba(234, 88, 12, 0.4)',
                transition: 'transform 0.2s',
                textTransform: 'uppercase',
              }}
              onMouseOver={(e) => { e.target.style.transform = 'translateY(-2px)'; }}
              onMouseOut={(e) => { e.target.style.transform = 'translateY(0)'; }}
            >
              {t('login') || 'LOGIN'}
            </button>
          </div>
        </div>
      </div>

      <div style={{ display: 'flex', justifyContent: 'center', padding: '16px', zIndex: 10 }}>
        <Footer />
      </div>
    </div>
  );
};

export default Login;
