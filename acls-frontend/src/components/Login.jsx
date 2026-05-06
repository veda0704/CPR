import React, { useState } from 'react';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useNavigate, Link } from 'react-router-dom';
import { login } from '../services/api';
import { User, Lock, Eye, EyeOff, Sun, Moon, ArrowRight, Settings } from 'lucide-react';
import iaclsLogo from '../assets/iacls-logo.png';
import bavyaLogo from '../assets/bavya-logo.png';
import loginHeroImg from '../assets/loginacls.png';
import SettingsPanel from './SettingsPanel';

const Login = ({ onLogin, theme, toggleTheme, themeColor, applyThemeColor }) => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(() => {
    return localStorage.getItem('remember_me') === 'true';
  });
  const [isLoading, setIsLoading] = useState(false);
  const [fieldErrors, setFieldErrors] = useState({ email: '', password: '' });
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  const validateEmail = (email) => {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(String(email).toLowerCase());
  };

  const handleEmailChange = (e) => {
    const value = e.target.value;
    setEmail(value);
    if (!value) {
      setFieldErrors(prev => ({ ...prev, email: i18n.language === 'te' ? 'ఇమెయిల్ అవసరం' : 'Email is required' }));
    } else if (!validateEmail(value)) {
      setFieldErrors(prev => ({ ...prev, email: i18n.language === 'te' ? 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి' : 'Enter a valid email' }));
    } else {
      setFieldErrors(prev => ({ ...prev, email: '' }));
    }
  };

  const handlePasswordChange = (e) => {
    const value = e.target.value;
    setPassword(value);
    if (!value) {
      setFieldErrors(prev => ({ ...prev, password: i18n.language === 'te' ? 'పాస్‌వర్డ్ అవసరం' : 'Password is required' }));
    } else if (value.length < 6) {
      setFieldErrors(prev => ({ ...prev, password: i18n.language === 'te' ? 'పాస్‌వర్డ్ కనీసం 6 అక్షరాలు ఉండాలి' : 'Password must be at least 6 characters' }));
    } else {
      setFieldErrors(prev => ({ ...prev, password: '' }));
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    
    // Final validation check before submit
    const newErrors = { email: '', password: '' };
    if (!email) newErrors.email = i18n.language === 'te' ? 'ఇమెయిల్ అవసరం' : 'Email is required';
    else if (!validateEmail(email)) newErrors.email = i18n.language === 'te' ? 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి' : 'Enter a valid email';
    
    if (!password) newErrors.password = i18n.language === 'te' ? 'పాస్‌వర్డ్ అవసరం' : 'Password is required';
    
    if (newErrors.email || newErrors.password) {
      setFieldErrors(newErrors);
      return;
    }

    setIsLoading(true);
    setError('');
    try {
      const res = await login(email, password, rememberMe);
      const storage = rememberMe ? localStorage : sessionStorage;
      storage.setItem('access_token', res.data.access);
      if (rememberMe) localStorage.setItem('remember_me', 'true');
      onLogin(res.data.user);
      toast.success(i18n.language === 'te' ? 'లాగిన్ విజయవంతమైంది!' : 'Login successful!');
      navigate('/dashboard');
    } catch (err) {
      const errorMsg = err.response?.data?.detail || t('invalid_credentials');
      setError(errorMsg);
      toast.error(errorMsg);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-split-container">
      {/* Left Panel - Branding */}
      <div className="login-left-panel">
        <div className="login-branding-top">
          <img src={iaclsLogo} alt="iACLS" className="login-panel-logo" />
        </div>
        
        <div className="login-illustration-container">
          <div className="illustration-glass-card">
            <img src={loginHeroImg} alt="Clinical Simulation" className="login-hero-img" />
          </div>
        </div>

        <div className="login-branding-bottom">
          <div className="login-controls-group">
             <button 
              className="settings-nav-btn"
              onClick={() => setIsSettingsOpen(true)}
              title={t('settings')}
              style={{ background: 'rgba(255,255,255,0.2)', border: 'none', color: 'white' }}
            >
              <Settings size={18} />
            </button>
          </div>
        </div>
      </div>

      {/* Right Panel - Login Form */}
      <div className="login-right-panel">
        <div className="login-form-wrapper">
          <h1 className="login-greeting">
            {t('welcome_back')} <span className="greeting-icon">👋</span>
          </h1>
          
          <form onSubmit={handleLogin} className="login-form-stack">
            <div className="login-input-wrapper">
              <div className={`login-input-group ${fieldErrors.email ? 'input-error' : ''}`}>
                <div className="login-input-icon"><User size={20} /></div>
                <input 
                  type="email" 
                  placeholder={t('email')} 
                  value={email}
                  onChange={handleEmailChange}
                  required 
                />
              </div>
              {fieldErrors.email && <div className="field-error-msg">{fieldErrors.email}</div>}
            </div>

            <div className="login-input-wrapper">
              <div className={`login-input-group ${fieldErrors.password ? 'input-error' : ''}`}>
                <div className="login-input-icon"><Lock size={20} /></div>
                <input 
                  type={showPassword ? "text" : "password"} 
                  placeholder={t('password')} 
                  value={password}
                  onChange={handlePasswordChange}
                  required 
                />
                <button type="button" className="pw-toggle" onClick={() => setShowPassword(!showPassword)}>
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
              {fieldErrors.password && <div className="field-error-msg">{fieldErrors.password}</div>}
            </div>

            <div className="login-extra-actions">
              <label className="login-remember">
                <input 
                  type="checkbox" 
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                />
                <span>{t('remember_me')}</span>
              </label>
            </div>

            {error && <div className="login-error-msg">{error}</div>}

            <button type="submit" className="login-submit-btn" disabled={isLoading}>
              {isLoading ? (
                <div className="login-btn-loader"></div>
              ) : (
                <>
                  <span>{t('login_btn')}</span>
                  <ArrowRight size={20} />
                </>
              )}
            </button>
          </form>

          <div className="login-signup-prompt">
            {t('signup_prompt')} <Link to="/signup">{t('signup_link')}</Link>
          </div>

          <div className="login-footer-branding">
            <span className="copyright">{t('copyright_text')}</span>
            <span className="footer-separator">•</span>
            <span className="powered-by">
              {t('powered_by')} <img src={bavyaLogo} alt="BAVYA" />
            </span>
          </div>
        </div>
      </div>

      <SettingsPanel 
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
        theme={theme}
        toggleTheme={toggleTheme}
        currentPrimary={themeColor}
        applyThemeColor={applyThemeColor}
      />

      <style dangerouslySetInnerHTML={{ __html: `
        .login-split-container {
          display: flex;
          height: 100vh;
          max-height: 100vh;
          background: var(--surface);
          font-family: 'Inter', sans-serif;
          overflow: hidden;
        }

        /* Left Panel */
        .login-left-panel {
          flex: 0 0 58%;
          height: 100%;
          background: var(--primary-color);
          background: linear-gradient(145deg, var(--primary-color) 0%, var(--primary-strong) 100%);
          display: flex;
          flex-direction: column;
          padding: 32px;
          position: relative;
          overflow: hidden;
        }

        .login-branding-top {
          display: flex;
          justify-content: center;
          align-items: center;
          width: 100%;
          position: absolute;
          top: 16px;
          left: 0;
          z-index: 20;
        }

        .login-panel-logo {
          height: 140px;
          object-fit: contain;
          filter: brightness(0) invert(1);
        }

        .login-illustration-container {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          width: 100%;
          height: 100%;
        }

        .illustration-glass-card {
          width: 100%;
          max-width: 620px;
          aspect-ratio: 16/10;
          background: rgba(255, 255, 255, 0.2);
          border-radius: 40px;
          padding: 24px;
          box-shadow: 0 40px 80px rgba(0, 0, 0, 0.2);
          border: 1px solid rgba(255, 255, 255, 0.3);
          overflow: hidden;
          transform: perspective(1000px) rotateY(-5deg);
          animation: float 6s ease-in-out infinite;
          transition: transform 0.4s ease;
        }

        @keyframes float {
          0%, 100% { transform: perspective(1000px) rotateY(-5deg) translateY(0); }
          50% { transform: perspective(1000px) rotateY(-5deg) translateY(-15px); }
        }

        .login-hero-img {
          width: 100%;
          height: 100%;
          object-fit: cover;
          border-radius: 28px;
        }

        .login-branding-bottom {
          display: flex;
          justify-content: flex-end;
          align-items: center;
          width: 100%;
          position: absolute;
          bottom: 32px;
          right: 32px;
          z-index: 10;
        }

        .login-controls-group {
          display: flex;
          align-items: center;
          gap: 20px;
          background: rgba(255, 255, 255, 0.1);
          padding: 8px;
          border-radius: 100px;
          border: 1px solid rgba(255, 255, 255, 0.2);
        }

        /* Right Panel */
        .login-right-panel {
          flex: 1;
          height: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 60px 24px;
          background: var(--bg-main);
          overflow-y: auto;
          scrollbar-width: none; /* Firefox */
        }
        .login-right-panel::-webkit-scrollbar { display: none; } /* Chrome/Safari */

        .login-form-wrapper {
          width: 100%;
          max-width: 380px;
          animation: fadeIn 0.6s ease-out;
        }

        .login-form-stack {
          display: flex;
          flex-direction: column;
          gap: 28px;
          margin-top: 32px;
        }

        .login-greeting {
          font-size: 2.1rem;
          font-weight: 900;
          color: var(--primary-color);
          margin-bottom: 0;
          letter-spacing: -0.04em;
          text-align: left;
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .login-input-group {
          position: relative;
          display: flex;
          align-items: center;
          border-bottom: 2px solid var(--border);
          transition: all 0.3s ease;
          padding-bottom: 8px;
        }

        .login-input-icon {
          position: absolute;
          left: 0;
          color: var(--text-muted);
          transition: color 0.3s ease;
        }

        .login-input-group:focus-within {
          border-color: var(--primary-color);
          transform: translateY(-1px);
        }

        .login-input-group:focus-within .login-input-icon {
          color: var(--primary-color);
        }

        .login-input-group input {
          width: 100%;
          border: none;
          background: none;
          padding: 10px 10px 10px 40px;
          font-size: 16px;
          font-weight: 600;
          color: var(--text-main);
          outline: none;
        }

        .login-input-group input::placeholder {
          color: var(--text-muted);
          opacity: 0.7;
        }

        .pw-toggle {
          background: none;
          border: none;
          color: var(--text-muted);
          cursor: pointer;
          padding: 8px;
          transition: color 0.3s ease;
        }

        .login-input-group:focus-within .pw-toggle {
          color: var(--primary-color);
        }

        .login-extra-actions {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .login-remember {
          display: flex;
          align-items: center;
          gap: 10px;
          cursor: pointer;
          color: var(--text-muted);
          font-size: 14px;
          font-weight: 600;
        }

        .login-remember input[type="checkbox"] {
          width: 18px;
          height: 18px;
          accent-color: var(--primary-color);
          cursor: pointer;
        }

        .login-submit-btn {
          height: 56px;
          background: var(--primary-color);
          color: white;
          border: none;
          border-radius: 16px;
          font-size: 17px;
          font-weight: 800;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 12px;
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: 0 12px 24px color-mix(in srgb, var(--primary-color), transparent 80%);
          width: 100%;
        }

        .login-submit-btn span {
          background: none;
          padding: 0;
          border: none;
        }

        .login-submit-btn:hover:not(:disabled) {
          background: var(--primary-strong);
          transform: translateY(-2px);
          box-shadow: 0 20px 40px color-mix(in srgb, var(--primary-color), transparent 70%);
        }

        .login-signup-prompt {
          margin-top: 24px;
          text-align: center;
          font-size: 15px;
          color: var(--text-muted);
          font-weight: 600;
        }

        .login-signup-prompt a {
          color: var(--primary-color);
          text-decoration: none;
          font-weight: 800;
          margin-left: 4px;
          transition: opacity 0.2s;
        }

        .login-signup-prompt a:hover {
          opacity: 0.8;
          text-decoration: underline;
        }

        [data-theme="dark"] .login-split-container { background: #0F172A; }
        [data-theme="dark"] .login-right-panel { background: #0F172A; }
        [data-theme="dark"] .login-greeting { color: #F8FAFC; }
        [data-theme="dark"] .login-input-group { border-color: #334155; }
        [data-theme="dark"] .login-input-group input { color: #F8FAFC; }
        [data-theme="dark"] .login-left-panel { background: linear-gradient(145deg, #071124 0%, #0F172A 100%); }

        .login-footer-branding {
          margin-top: 60px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 12px;
          color: var(--text-muted);
          font-size: 0.82rem;
          font-weight: 700;
          width: 100%;
        }

        .login-footer-branding span {
          white-space: nowrap;
          display: flex;
          align-items: center;
        }

        .login-footer-branding img {
          height: 28px;
          margin-left: 8px;
          display: inline-block;
          vertical-align: middle;
          transition: transform 0.3s ease;
        }

        .login-footer-branding img:hover {
          transform: scale(1.05);
        }

        .footer-separator {
          opacity: 0.3;
          margin: 0 4px;
        }

        .powered-by {
          display: flex;
          align-items: center;
          gap: 2px;
        }
      ` }} />
    </div>
  );
};

export default Login;
