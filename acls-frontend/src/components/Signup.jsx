import React, { useState } from 'react';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useNavigate, Link } from 'react-router-dom';
import { signup } from '../services/api';
import { UserPlus, User, Lock, Mail } from 'lucide-react';
import Footer from './Footer';
import iaclsLogo from '../assets/iacls-logo.png';

const Signup = () => {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    first_name: '',
    last_name: '',
    password: '',
    confirm_password: ''
  });
  const [errors, setErrors] = useState({});

  const toggleLanguage = (lang) => {
    i18n.changeLanguage(lang);
    localStorage.setItem('i18nextLng', lang);
  };

  const handleSignup = async (e) => {
    e.preventDefault();
    setErrors({});
    try {
      await signup(formData);
      toast.success(t('signup_success'), {
        duration: 5000,
        style: {
          background: '#9a3412',
          color: '#fff',
          fontWeight: 'bold',
          borderRadius: '12px',
          border: '2px solid #fb923c'
        },
        iconTheme: {
          primary: '#fff',
          secondary: '#9a3412',
        },
      });
      navigate('/login');
    } catch (err) {
      console.error(err);
      const errorMsg = err.response?.data ? Object.values(err.response.data)[0][0] : (i18n.language === 'te' ? 'ఏదో పొరపాటు జరిగింది.' : 'Something went wrong.');
      toast.error(errorMsg, {
        style: {
          background: '#ef4444',
          color: '#fff',
          fontWeight: 'bold'
        }
      });
      if (err.response && err.response.data) {
        setErrors(err.response.data);
      } else {
        setErrors({ general: i18n.language === 'te' ? 'ఏదో పొరపాటు జరిగింది.' : 'Something went wrong.' });
      }
    }
  };

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const registrationFailedLabel = i18n.language === 'te' ? 'నమోదు విఫలమైంది' : 'Registration failed';

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100%', paddingBottom: '24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '4px 32px', zIndex: 10 }}>
        <img src={iaclsLogo} alt="iACLS Logo" style={{ height: '90px', objectFit: 'contain', mixBlendMode: 'multiply' }} />
        <div style={{ display: 'flex', gap: '8px' }}>
          <button onClick={() => toggleLanguage('en')} style={{ background: i18n.language === 'en' ? '#ea580c' : 'rgba(255,255,255,0.6)', color: i18n.language === 'en' ? '#fff' : '#9a3412', border: 'none', padding: '6px 16px', borderRadius: '20px', fontWeight: 'bold', cursor: 'pointer', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>EN</button>
          <button onClick={() => toggleLanguage('te')} style={{ background: i18n.language === 'te' ? '#ea580c' : 'rgba(255,255,255,0.6)', color: i18n.language === 'te' ? '#fff' : '#9a3412', border: 'none', padding: '6px 16px', borderRadius: '20px', fontWeight: 'bold', cursor: 'pointer', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>తెలుగు</button>
        </div>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0px 16px', zIndex: 10, overflowY: 'auto' }}>
        <div style={{ position: 'relative', width: '100%', maxWidth: '500px', marginTop: '0px' }}>
          <div
            style={{
              background: 'rgba(255, 255, 255, 0.4)',
              backdropFilter: 'blur(20px)',
              WebkitBackdropFilter: 'blur(20px)',
              border: '1px solid rgba(255,255,255,0.6)',
              borderRadius: '24px',
              padding: '48px 40px 16px 40px',
              boxShadow: '0 24px 48px rgba(154, 52, 18, 0.08)',
              position: 'relative',
            }}
          >
            <div
              style={{
                position: 'absolute',
                top: '-42px',
                left: '50%',
                transform: 'translateX(-50%)',
                width: '84px',
                height: '84px',
                borderRadius: '50%',
                background: '#9a3412',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 16px 32px rgba(154, 52, 18, 0.4)',
                border: '4px solid #ffffff',
              }}
            >
              <UserPlus size={36} color="#ffffff" style={{ marginLeft: '4px' }} />
            </div>

            <form onSubmit={handleSignup} id="signup-form" style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: '12px' }}>
                <div style={{ display: 'flex', height: '46px', overflow: 'hidden', borderRadius: '8px', boxShadow: '0 4px 10px rgba(0,0,0,0.05)' }}>
                  <div style={{ width: '46px', background: '#9a3412', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <User size={16} color="#ffffff" />
                  </div>
                  <input
                    name="first_name"
                    value={formData.first_name}
                    onChange={handleChange}
                    placeholder={t('first_name')}
                    style={{ flex: 1, border: 'none', background: 'rgba(255, 255, 255, 0.9)', padding: '0 12px', fontSize: '14px', color: '#111827', outline: 'none', width: '100%' }}
                    required
                  />
                </div>

                <div style={{ display: 'flex', height: '46px', overflow: 'hidden', borderRadius: '8px', boxShadow: '0 4px 10px rgba(0,0,0,0.05)' }}>
                  <div style={{ width: '46px', background: '#9a3412', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <User size={16} color="#ffffff" />
                  </div>
                  <input
                    name="last_name"
                    value={formData.last_name}
                    onChange={handleChange}
                    placeholder={t('last_name')}
                    style={{ flex: 1, border: 'none', background: 'rgba(255, 255, 255, 0.9)', padding: '0 12px', fontSize: '14px', color: '#111827', outline: 'none', width: '100%' }}
                    required
                  />
                </div>
              </div>

              <div style={{ display: 'flex', height: '46px', overflow: 'hidden', borderRadius: '8px', boxShadow: '0 4px 10px rgba(0,0,0,0.05)' }}>
                <div style={{ width: '46px', background: '#9a3412', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <Mail size={16} color="#ffffff" />
                </div>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  placeholder={t('email')}
                  style={{ flex: 1, border: 'none', background: 'rgba(255, 255, 255, 0.9)', padding: '0 16px', fontSize: '14px', color: '#111827', outline: 'none' }}
                  required
                />
              </div>

              <div style={{ display: 'flex', height: '46px', overflow: 'hidden', borderRadius: '8px', boxShadow: '0 4px 10px rgba(0,0,0,0.05)' }}>
                <div style={{ width: '46px', background: '#9a3412', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <Lock size={16} color="#ffffff" />
                </div>
                <input
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  placeholder={t('password')}
                  style={{ flex: 1, border: 'none', background: 'rgba(255, 255, 255, 0.9)', padding: '0 16px', fontSize: '14px', color: '#111827', outline: 'none' }}
                  required
                />
              </div>

              <div style={{ display: 'flex', height: '46px', overflow: 'hidden', borderRadius: '8px', boxShadow: '0 4px 10px rgba(0,0,0,0.05)' }}>
                <div style={{ width: '46px', background: '#9a3412', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <Lock size={16} color="#ffffff" />
                </div>
                <input
                  type="password"
                  name="confirm_password"
                  value={formData.confirm_password}
                  onChange={handleChange}
                  placeholder={t('confirm_password')}
                  style={{ flex: 1, border: 'none', background: 'rgba(255, 255, 255, 0.9)', padding: '0 16px', fontSize: '14px', color: '#111827', outline: 'none' }}
                  required
                />
              </div>

              {errors && Object.keys(errors).length > 0 && (
                <div style={{ color: '#ef4444', fontSize: '13px', fontWeight: 600, textAlign: 'center', marginTop: '0px' }}>
                  {Object.values(errors)[0][0] || registrationFailedLabel}
                </div>
              )}
            </form>

            <div style={{ textAlign: 'center', marginTop: '16px', paddingBottom: '16px' }}>
              <span style={{ fontSize: '14px', color: '#9a3412', fontWeight: 500 }}>
                {t('already_have_account')} <Link to="/login" style={{ color: '#ea580c', fontWeight: 800, textDecoration: 'none' }}>{t('login')}</Link>
              </span>
            </div>
          </div>

          <div style={{ position: 'relative', marginTop: '-24px', display: 'flex', justifyContent: 'center', zIndex: 12 }}>
            <button
              type="submit"
              form="signup-form"
              style={{
                padding: '0',
                height: '48px',
                width: '260px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
                background: 'linear-gradient(135deg, #fb923c 0%, #ea580c 100%)',
                color: '#ffffff',
                border: 'none',
                borderRadius: '14px',
                fontSize: '15px',
                fontWeight: 800,
                letterSpacing: '1px',
                cursor: 'pointer',
                boxShadow: '0 8px 24px rgba(234, 88, 12, 0.4)',
                transition: 'transform 0.2s',
                textTransform: 'uppercase',
              }}
              onMouseOver={(e) => { e.target.style.transform = 'translateY(-2px)'; }}
              onMouseOut={(e) => { e.target.style.transform = 'translateY(0)'; }}
            >
              {t('signup') || 'SIGN UP'}
            </button>
          </div>
        </div>
      </div>

      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px', zIndex: 10 }}>
        <Footer />
      </div>
    </div>
  );
};

export default Signup;
