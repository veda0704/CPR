import React from 'react';
import { useTranslation } from 'react-i18next';
import bavyaLogo from '../assets/bavya-logo.png';

const Footer = () => {
  const { i18n } = useTranslation();

  return (
    <footer style={{ padding: '2px 20px', display: 'flex', flexDirection: 'column', alignItems: 'center', opacity: 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', color: 'var(--text-muted)', fontWeight: 700 }}>
        <span>© 2026 | {i18n.language === 'te' ? 'పవర్డ్ బై' : 'Powered by'}</span>
        <img src={bavyaLogo} alt="Bavya" style={{ height: '18px' }} />
      </div>
    </footer>
  );
};

export default Footer;
