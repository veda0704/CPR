import React, { useState } from 'react';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useNavigate, Link } from 'react-router-dom';
import { login } from '../services/api';
import { User, Lock, Eye, EyeOff, Sun, Moon, ArrowRight } from 'lucide-react';
import iaclsLogo from '../assets/iacls-logo.png';
import bavyaLogo from '../assets/bavya-logo.png';
import loginHeroImg from '../assets/loginacls.png';

const Login = ({ onLogin, theme, toggleTheme }) => {
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
      {/* Left Panel - Pastel Green Branding */}
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
            <div className="login-lang-toggle">
              {i18n.language === 'en' ? (
                <button onClick={() => { i18n.changeLanguage('te'); localStorage.setItem('i18nextLng', 'te'); }} className="lang-icon-btn">తె</button>
              ) : (
                <button onClick={() => { i18n.changeLanguage('en'); localStorage.setItem('i18nextLng', 'en'); }} className="lang-icon-btn">EN</button>
              )}
            </div>
            <div className="login-theme-toggle" onClick={toggleTheme}>
              {theme === 'dark' ? <Sun size={18} /> : <Moon size={18} />}
            </div>
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
              <Link to="/forgot-password" title="Coming Soon" className="login-forgot">{t('forgot_password')}</Link>
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
            <span className="powered-by">
              {t('powered_by')} <img src={bavyaLogo} alt="BAVYA" />
            </span>
          </div>
        </div>
      </div>

      <style dangerouslySetInnerHTML={{ __html: `
        .login-split-container {
          display: flex;
          height: 100vh;
          background: #fff;
          font-family: 'Inter', sans-serif;
        }

        /* Left Panel */
        .login-left-panel {
          flex: 0 0 58%;
          background: #E0F2F1;
          background: linear-gradient(145deg, #E0F2F1 0%, #B2DFDB 100%);
          display: flex;
          flex-direction: column;
          padding: 32px;
          position: relative;
          overflow: hidden;
        }

        .login-branding-top {
          display: flex;
          justify-content: center;
          width: 100%;
        }

        .login-panel-logo {
          height: 150px;
          object-fit: contain;
          filter: drop-shadow(0 4px 12px rgba(0, 121, 107, 0.1));
        }

        .login-illustration-container {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .illustration-glass-card {
          width: 100%;
          max-width: 620px;
          aspect-ratio: 16/10;
          background: rgba(255, 255, 255, 0.4);
          border-radius: 40px;
          padding: 24px;
          box-shadow: 0 40px 80px rgba(0, 77, 64, 0.2);
          border: 1px solid rgba(255, 255, 255, 0.6);
          overflow: hidden;
          transform: perspective(1000px) rotateY(-5deg);
          animation: float 6s ease-in-out infinite;
          transition: transform 0.4s ease;
        }

        .illustration-glass-card:hover {
          transform: perspective(1000px) rotateY(-2deg) translateY(-5px);
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
        }

        .lang-icon-btn {
          font-family: 'Inter', sans-serif;
          font-weight: 800;
          font-size: 14px;
          color: #00796B;
          background: rgba(0, 121, 107, 0.1);
          width: 32px;
          height: 32px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          border: 1px solid rgba(0, 121, 107, 0.2);
          cursor: pointer;
          transition: all 0.3s ease;
        }

        .lang-icon-btn:hover {
          background: #00796B;
          color: #fff;
          transform: scale(1.1);
        }

        .login-controls-group {
          display: flex;
          align-items: center;
          gap: 20px;
          background: rgba(255, 255, 255, 0.6);
          padding: 8px 16px;
          border-radius: 100px;
          border: 1px solid rgba(255, 255, 255, 0.8);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        .login-lang-toggle {
          display: flex;
          align-items: center;
          gap: 10px;
          font-size: 14px;
          font-weight: 700;
        }

        .login-theme-toggle {
          cursor: pointer;
          color: #00695C;
          display: flex;
          transition: transform 0.3s ease;
        }

        .login-theme-toggle:hover {
          transform: rotate(15deg) scale(1.1);
        }

        /* Right Panel */
        .login-right-panel {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 24px;
          background: #fff;
        }

        .login-form-wrapper {
          width: 100%;
          max-width: 380px;
          animation: fadeIn 0.6s ease-out;
        }

        .login-greeting {
          font-size: 2.1rem;
          font-weight: 900;
          color: #00796B;
          margin-bottom: 20px;
          letter-spacing: -0.04em;
          text-align: left;
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .greeting-icon {
          font-size: 1.8rem;
        }

        .login-form-stack {
          display: flex;
          flex-direction: column;
          gap: 20px;
        }

        .login-input-group {
          position: relative;
          display: flex;
          align-items: center;
          border-bottom: 2px solid #E2E8F0;
          transition: all 0.3s ease;
          padding-bottom: 4px;
        }

        .login-input-group:hover {
          border-color: #CBD5E1;
        }

        .login-input-group:focus-within {
          border-color: #00796B;
          transform: translateY(-1px);
        }

        .login-input-group input {
          width: 100%;
          border: none;
          background: none;
          padding: 10px 10px 10px 40px;
          font-size: 16px;
          font-weight: 600;
          color: #1E293B;
          outline: none;
        }

        .login-input-group.input-error {
          border-color: #ef4444 !important;
        }

        .field-error-msg {
          color: #ef4444;
          font-size: 12px;
          font-weight: 700;
          margin-top: 4px;
          animation: slideIn 0.3s ease-out;
        }

        @keyframes slideIn {
          from { opacity: 0; transform: translateY(-5px); }
          to { opacity: 1; transform: translateY(0); }
        }

        .login-input-icon {
          position: absolute;
          left: 0;
          color: #94A3B8;
          transition: all 0.3s ease;
        }

        .login-input-group:focus-within .login-input-icon {
          color: #00796B;
          transform: scale(1.1);
        }

        .pw-toggle {
          position: absolute;
          right: 0;
          background: none;
          border: none;
          color: #94A3B8;
          cursor: pointer;
          display: flex;
          padding: 8px;
          transition: color 0.3s ease;
        }

        .pw-toggle:hover {
          color: #00796B;
        }

        .login-extra-actions {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-top: 4px;
        }

        .login-remember {
          display: flex;
          align-items: center;
          gap: 8px;
          font-size: 14px;
          font-weight: 600;
          color: #64748B;
          cursor: pointer;
          transition: color 0.3s ease;
        }

        .login-remember:hover {
          color: #1E293B;
        }

        .login-forgot {
          color: #00796B;
          font-weight: 700;
          font-size: 14px;
          text-decoration: none;
          transition: opacity 0.3s ease;
        }

        .login-forgot:hover {
          opacity: 0.8;
          text-decoration: underline;
        }

        .login-submit-btn {
          height: 56px;
          background: var(--primary, #00796B);
          color: #fff;
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
          box-shadow: 0 12px 24px rgba(0, 121, 107, 0.15);
          margin-top: 8px;
          position: relative;
          overflow: hidden;
        }

        .login-submit-btn:hover:not(:disabled) {
          background: var(--primary-strong, #00695C);
          transform: translateY(-2px) scale(1.02);
          box-shadow: 0 20px 40px rgba(0, 121, 107, 0.25);
        }

        .login-submit-btn:active:not(:disabled) {
          transform: translateY(0) scale(0.98);
        }

        .login-submit-btn:disabled {
          opacity: 0.7;
          cursor: not-allowed;
        }

        .login-btn-loader {
          width: 24px;
          height: 24px;
          border: 3px solid rgba(255, 255, 255, 0.3);
          border-radius: 50%;
          border-top-color: #fff;
          animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }

        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(10px); }
          to { opacity: 1; transform: translateY(0); }
        }

        .login-signup-prompt {
          text-align: center;
          margin-top: 24px;
          font-size: 15px;
          font-weight: 600;
          color: #64748B;
        }

        .login-signup-prompt a {
          color: #00796B;
          font-weight: 800;
          text-decoration: none;
          transition: color 0.3s ease;
        }

        .login-signup-prompt a:hover {
          color: #004D40;
          text-decoration: underline;
        }

        .login-footer-branding {
          margin-top: 32px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding-top: 20px;
          border-top: 1px solid #F1F5F9;
        }

        .copyright {
          font-size: 13px;
          color: #64748B;
          font-weight: 600;
        }

        .powered-by {
          font-size: 13px;
          color: #64748B;
          display: flex;
          align-items: center;
          gap: 8px;
          font-weight: 700;
        }

        .powered-by img {
          height: 20px;
          object-fit: contain;
          transition: transform 0.3s ease;
        }

        .powered-by:hover img {
          transform: scale(1.1);
        }

        /* Mobile Adjustments */
        @media (max-width: 1024px) {
          .login-left-panel {
            display: none;
          }
          .login-right-panel {
            padding: 24px;
          }
          .login-form-wrapper {
            max-width: 100%;
          }
        }

        /* Dark Mode Overrides */
        [data-theme="dark"] .login-split-container {
          background: #0F172A;
        }

        [data-theme="dark"] .login-left-panel {
          background: linear-gradient(145deg, #071124 0%, #0F172A 100%);
          color: #81C784;
          border-right: 1px solid rgba(255, 255, 255, 0.05);
        }

        [data-theme="dark"] .login-right-panel {
          background: #0F172A;
        }

        [data-theme="dark"] .login-greeting {
          color: #F8FAFC;
        }

        [data-theme="dark"] .login-input-group {
          border-color: #334155;
        }

        [data-theme="dark"] .login-input-group input {
          color: #F8FAFC;
        }

        [data-theme="dark"] .login-input-group:focus-within {
          border-color: #00796B;
        }

        [data-theme="dark"] .login-remember {
          color: #94A3B8;
        }

        [data-theme="dark"] .illustration-glass-card {
          background: rgba(255, 255, 255, 0.03);
          border-color: rgba(255, 255, 255, 0.08);
          box-shadow: 0 40px 80px rgba(0, 0, 0, 0.4);
        }

        [data-theme="dark"] .login-controls-group {
          background: rgba(255, 255, 255, 0.05);
          border-color: rgba(255, 255, 255, 0.1);
        }

        [data-theme="dark"] .login-lang-toggle button {
          color: #81C784;
        }

        [data-theme="dark"] .login-theme-toggle {
          color: #81C784;
        }

        [data-theme="dark"] .login-footer-branding {
          border-color: rgba(255, 255, 255, 0.05);
        }
      ` }} />
    </div>
  );
};

export default Login;
