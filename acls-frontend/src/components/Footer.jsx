import React from 'react';
import { useTranslation } from 'react-i18next';
import bavyaLogo from '../assets/bavya-logo.png';

const Footer = () => {
  const { i18n } = useTranslation();

  return (
    <footer className="app-footer">
      <div className="footer-content">
        <span className="footer-copyright">© 2026 iACLS</span>
        <div className="footer-divider"></div>
        <div className="footer-powered">
          <span>{i18n.language === 'te' ? 'పవర్డ్ బై' : 'Powered by'}</span>
          <img src={bavyaLogo} alt="Bavya" />
        </div>
      </div>
    </footer>
  );
};

export default Footer;
