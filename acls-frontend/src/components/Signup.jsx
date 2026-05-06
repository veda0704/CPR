import React, { useState } from 'react';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useNavigate, Link } from 'react-router-dom';
import { signup } from '../services/api';
import { User, Lock, Mail, Shield, Eye, EyeOff, UserPlus, Sun, Moon, Settings } from 'lucide-react';
import iaclsLogo from '../assets/iacls-logo.png';
import bavyaLogo from '../assets/bavya-logo.png';
import loginHeroImg from '../assets/loginacls.png';
import SettingsPanel from './SettingsPanel';

const Signup = ({ theme, toggleTheme, themeColor, applyThemeColor }) => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    first_name: '',
    last_name: '',
    password: '',
    confirm_password: ''
  });
  const [fieldErrors, setFieldErrors] = useState({});
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  const validateEmail = (email) => {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(String(email).toLowerCase());
  };

  const validateField = (name, value) => {
    let error = '';
    const isTe = i18n.language === 'te';
    
    switch (name) {
      case 'first_name':
        if (!value) error = isTe ? 'మొదటి పేరు అవసరం' : 'First name is required';
        break;
      case 'last_name':
        if (!value) error = isTe ? 'చివరి పేరు అవసరం' : 'Last name is required';
        break;
      case 'email':
        if (!value) error = isTe ? 'ఇమెయిల్ అవసరం' : 'Email is required';
        else if (!validateEmail(value)) error = isTe ? 'చెల్లుబాటు అయ్యే ఇమెయిల్ నమోదు చేయండి' : 'Enter a valid email';
        break;
      case 'password':
        if (!value) error = isTe ? 'పాస్‌వర్డ్ అవసరం' : 'Password is required';
        else if (value.length < 8) error = isTe ? 'పాస్‌వర్డ్ కనీసం 8 అక్షరాలు ఉండాలి' : 'Password must be at least 8 characters';
        break;
      case 'confirm_password':
        if (!value) error = isTe ? 'పాస్‌వర్డ్ నిర్ధారణ అవసరం' : 'Confirm password is required';
        else if (value !== formData.password) error = isTe ? 'పాస్‌వర్డ్‌లు సరిపోలడం లేదు' : 'Passwords do not match';
        break;
      default:
        break;
    }
    return error;
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    const newErrors = {};
    Object.keys(formData).forEach(key => {
      const error = validateField(key, formData[key]);
      if (error) newErrors[key] = error;
    });

    if (Object.keys(newErrors).length > 0) {
      setFieldErrors(newErrors);
      return;
    }

    setIsLoading(true);
    try {
      await signup({
        email: formData.email,
        password: formData.password,
        confirm_password: formData.confirm_password,
        first_name: formData.first_name,
        last_name: formData.last_name,
      });
      toast.success(t('signup_success'));
      navigate('/login');
    } catch (err) {
      const errorData = err.response?.data || {};
      toast.error(errorData.detail || 'Registration failed');
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
    const error = validateField(name, value);
    setFieldErrors(prev => ({ ...prev, [name]: error }));
  };

  return (
    <div className="login-split-container">
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

      <div className="login-right-panel">
        <div className="login-form-wrapper">
          <h1 className="login-greeting">
            {t('join_iacls', 'Join iACLS')} <span className="greeting-icon">✨</span>
          </h1>
          
          <form onSubmit={handleSignup} className="login-form-stack">
            <div className="name-row" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
              <div className="login-input-wrapper">
                <div className={`login-input-group ${fieldErrors.first_name ? 'input-error' : ''}`}>
                  <div className="login-input-icon"><User size={20} /></div>
                  <input name="first_name" placeholder={t('first_name')} value={formData.first_name} onChange={handleChange} required />
                </div>
                {fieldErrors.first_name && <div className="field-error-msg">{fieldErrors.first_name}</div>}
              </div>
              <div className="login-input-wrapper">
                <div className={`login-input-group ${fieldErrors.last_name ? 'input-error' : ''}`}>
                  <div className="login-input-icon"><User size={20} /></div>
                  <input name="last_name" placeholder={t('last_name')} value={formData.last_name} onChange={handleChange} required />
                </div>
                {fieldErrors.last_name && <div className="field-error-msg">{fieldErrors.last_name}</div>}
              </div>
            </div>

            <div className="login-input-wrapper">
              <div className={`login-input-group ${fieldErrors.email ? 'input-error' : ''}`}>
                <div className="login-input-icon"><Mail size={20} /></div>
                <input type="email" name="email" placeholder={t('email')} value={formData.email} onChange={handleChange} required />
              </div>
              {fieldErrors.email && <div className="field-error-msg">{fieldErrors.email}</div>}
            </div>

            <div className="login-input-wrapper">
              <div className={`login-input-group ${fieldErrors.password ? 'input-error' : ''}`}>
                <div className="login-input-icon"><Lock size={20} /></div>
                <input 
                  type={showPassword ? "text" : "password"} 
                  name="password"
                  placeholder={t('password')} 
                  value={formData.password}
                  onChange={handleChange}
                  required 
                />
                <button type="button" className="pw-toggle" onClick={() => setShowPassword(!showPassword)}>
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
              {fieldErrors.password && <div className="field-error-msg">{fieldErrors.password}</div>}
            </div>

            <div className="login-input-wrapper">
              <div className={`login-input-group ${fieldErrors.confirm_password ? 'input-error' : ''}`}>
                <div className="login-input-icon"><Shield size={20} /></div>
                <input 
                  type={showPassword ? "text" : "password"} 
                  name="confirm_password"
                  placeholder={t('confirm_password')} 
                  value={formData.confirm_password}
                  onChange={handleChange}
                  required 
                />
              </div>
              {fieldErrors.confirm_password && <div className="field-error-msg">{fieldErrors.confirm_password}</div>}
            </div>

            <button type="submit" className="login-submit-btn" disabled={isLoading}>
              {isLoading ? (
                <div className="login-btn-loader"></div>
              ) : (
                <>
                  <span>{t('signup_link')}</span>
                  <UserPlus size={20} />
                </>
              )}
            </button>
          </form>

          <div className="login-signup-prompt">
            {t('already_have_account')} <Link to="/login">{t('login')}</Link>
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
        .login-split-container { display: flex; height: 100vh; max-height: 100vh; background: var(--surface); font-family: 'Inter', sans-serif; overflow: hidden; }
        .login-left-panel { flex: 0 0 58%; height: 100%; background: var(--primary-color); background: linear-gradient(145deg, var(--primary-color) 0%, var(--primary-strong) 100%); display: flex; flex-direction: column; padding: 32px; position: relative; overflow: hidden; }
        .login-hero-img { width: 100%; height: 100%; object-fit: cover; border-radius: 28px; }
        .login-branding-top { display: flex; justify-content: center; align-items: center; width: 100%; position: absolute; top: 16px; left: 0; z-index: 20; }
        .login-panel-logo { height: 140px; object-fit: contain; filter: brightness(0) invert(1); }
        .login-illustration-container { flex: 1; display: flex; align-items: center; justify-content: center; width: 100%; height: 100%; }
        
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

        .login-branding-bottom { display: flex; justify-content: flex-end; align-items: center; width: 100%; position: absolute; bottom: 32px; right: 32px; z-index: 10; }
        .login-right-panel { flex: 1; height: 100%; display: flex; align-items: center; justify-content: center; padding: 60px 24px; background: var(--bg-main); overflow-y: auto; scrollbar-width: none; }
        .login-right-panel::-webkit-scrollbar { display: none; }
        
        .login-form-stack {
          display: flex;
          flex-direction: column;
          gap: 28px;
          margin-top: 32px;
        }

        .login-greeting { font-size: 2.1rem; font-weight: 900; color: var(--primary-color); margin-bottom: 0; letter-spacing: -0.04em; }
        .login-input-group { position: relative; display: flex; align-items: center; border-bottom: 2px solid var(--border); padding-bottom: 8px; transition: all 0.3s; }
        .login-input-icon { position: absolute; left: 0; color: var(--text-muted); transition: color 0.3s ease; }
        .login-input-group:focus-within { border-color: var(--primary-color); transform: translateY(-1px); }
        .login-input-group:focus-within .login-input-icon { color: var(--primary-color); }
        .login-input-group input { width: 100%; border: none; background: none; padding: 10px 10px 10px 40px; font-size: 16px; font-weight: 600; color: var(--text-main); outline: none; }
        .login-input-group input::placeholder { color: var(--text-muted); opacity: 0.7; }
        .pw-toggle { background: none; border: none; color: var(--text-muted); cursor: pointer; padding: 8px; transition: color 0.3s ease; }
        .login-input-group:focus-within .pw-toggle { color: var(--primary-color); }
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
          transition: all 0.3s;
          box-shadow: 0 12px 24px color-mix(in srgb, var(--primary-color), transparent 80%);
          width: 100%;
        }

        .login-submit-btn span { background: none; padding: 0; border: none; }
        .login-submit-btn:hover:not(:disabled) { background: var(--primary-strong); transform: translateY(-2px); box-shadow: 0 20px 40px color-mix(in srgb, var(--primary-color), transparent 70%); }
        .login-signup-prompt { margin-top: 24px; text-align: center; font-size: 15px; color: var(--text-muted); font-weight: 600; }
        .login-signup-prompt a { color: var(--primary-color); text-decoration: none; font-weight: 800; margin-left: 4px; transition: opacity 0.2s; }
        .login-signup-prompt a:hover { opacity: 0.8; text-decoration: underline; }

        [data-theme="dark"] .login-split-container { background: #0F172A; }
        [data-theme="dark"] .login-right-panel { background: #0F172A; }
        [data-theme="dark"] .login-greeting { color: #F8FAFC; }
        [data-theme="dark"] .login-input-group { border-color: #334155; }
        [data-theme="dark"] .login-input-group input { color: #F8FAFC; }
        [data-theme="dark"] .login-left-panel { background: linear-gradient(145deg, #071124 0%, #0F172A 100%); }

        .login-footer-branding { margin-top: 60px; display: flex; align-items: center; justify-content: center; gap: 12px; color: var(--text-muted); font-size: 0.82rem; font-weight: 700; width: 100%; }
        .login-footer-branding span { white-space: nowrap; display: flex; align-items: center; }
        .login-footer-branding img { height: 28px; margin-left: 8px; display: inline-block; vertical-align: middle; transition: transform 0.3s ease; }
        .login-footer-branding img:hover { transform: scale(1.05); }

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

export default Signup;
