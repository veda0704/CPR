import React from 'react';
import { useTranslation } from 'react-i18next';

const LanguageSelector = ({ className = '', style = {} }) => {
  const { i18n } = useTranslation();

  return (
    <div 
      className={`language-selector ${className}`} 
      style={{
        ...style,
        background: 'rgba(0, 0, 0, 0.04)',
        padding: '4px',
        borderRadius: '12px',
        display: 'flex',
        gap: '4px',
        alignItems: 'center'
      }}
    >
      <button
        onClick={() => {
          i18n.changeLanguage('en');
          localStorage.setItem('i18nextLng', 'en');
        }}
        className={i18n.language === 'en' ? 'active' : ''}
        style={{
          background: i18n.language === 'en' ? '#8A5E44' : 'transparent',
          color: i18n.language === 'en' ? 'white' : '#64748B',
          border: 'none',
          padding: '6px 16px',
          borderRadius: '10px',
          fontSize: '13px',
          fontWeight: 900,
          cursor: 'pointer',
          transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
          boxShadow: i18n.language === 'en' ? '0 4px 12px rgba(138, 94, 68, 0.2)' : 'none',
        }}
      >
        EN
      </button>
      <button
        onClick={() => {
          i18n.changeLanguage('te');
          localStorage.setItem('i18nextLng', 'te');
        }}
        className={i18n.language === 'te' ? 'active' : ''}
        style={{
          background: i18n.language === 'te' ? '#8A5E44' : 'transparent',
          color: i18n.language === 'te' ? 'white' : '#64748B',
          border: 'none',
          padding: '6px 16px',
          borderRadius: '10px',
          fontSize: '14px',
          fontWeight: 800,
          cursor: 'pointer',
          transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
          boxShadow: i18n.language === 'te' ? '0 4px 12px rgba(138, 94, 68, 0.2)' : 'none',
        }}
      >
        తెలుగు
      </button>
    </div>
  );
};

export default LanguageSelector;
