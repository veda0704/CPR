import React from 'react';
import { useTranslation } from 'react-i18next';
import bavyaLogo from '../assets/bavya-logo.png';

const Footer = () => {
  const { i18n } = useTranslation();

  return (
    <footer className="site-footer" style={{
      marginTop: 'auto',
      padding: '24px 20px',
      textAlign: 'center',
      color: 'var(--muted)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: '8px'
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '16px', fontWeight: 500 }}>
        <span>&copy; 2025 | {i18n.language === 'te' ? 'శక్తినిచ్చింది' : 'Powered by'}</span>
        <img src={bavyaLogo} alt="Bavya" style={{ height: '24px', width: 'auto', objectFit: 'contain' }} />
      </div>
    </footer>
  );
};

export default Footer;
