import React from 'react';
import { useTranslation } from 'react-i18next';
import { X, Moon, Sun, Palette, Globe, Check } from 'lucide-react';

const themes = {
  teal: "#005B41",
  maroon: "#8B0000",
  orange: "#F57C00",
  brown: "#6D4C41",
  charcoal: "#1F2937",
  indigo: "#4F46E5",
};

const SettingsPanel = ({ isOpen, onClose, theme, toggleTheme, currentPrimary, applyThemeColor }) => {
  const { t, i18n } = useTranslation();

  if (!isOpen) return null;

  const changeLanguage = (lng) => {
    i18n.changeLanguage(lng);
    localStorage.setItem('i18nextLng', lng);
  };

  return (
    <div className="settings-overlay animate-reveal" onClick={onClose}>
      <div className="settings-panel" onClick={(e) => e.stopPropagation()}>
        <div className="settings-header">
          <div className="settings-title-group">
            <Palette size={20} className="settings-icon-accent" />
            <h2 className="settings-title">{t('settings') || 'Settings'}</h2>
          </div>
          <button className="settings-close-btn" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        <div className="settings-body">
          {/* Theme Color Selection */}
          <div className="settings-section">
            <label className="settings-label">{t('theme_color') || 'Theme Color'}</label>
            <div className="theme-color-grid">
              {Object.entries(themes).map(([name, color]) => (
                <button
                  key={name}
                  className={`theme-color-btn ${currentPrimary === color ? 'active' : ''}`}
                  style={{ '--btn-color': color }}
                  onClick={() => applyThemeColor(color)}
                  title={name}
                >
                  {currentPrimary === color && <Check size={16} color="white" />}
                </button>
              ))}
            </div>
          </div>

          {/* Appearance Mode */}
          <div className="settings-section">
            <label className="settings-label">{t('appearance') || 'Appearance'}</label>
            <div className="settings-toggle-group">
              <button 
                className={`settings-toggle-btn ${theme === 'light' ? 'active' : ''}`}
                onClick={() => theme === 'dark' && toggleTheme()}
              >
                <Sun size={16} />
                <span>{t('light') || 'Light'}</span>
              </button>
              <button 
                className={`settings-toggle-btn ${theme === 'dark' ? 'active' : ''}`}
                onClick={() => theme === 'light' && toggleTheme()}
              >
                <Moon size={16} />
                <span>{t('dark') || 'Dark'}</span>
              </button>
            </div>
          </div>

          {/* Language Selection */}
          <div className="settings-section">
            <label className="settings-label">{t('language') || 'Language'}</label>
            <div className="settings-toggle-group">
              <button 
                className={`settings-toggle-btn ${i18n.language === 'en' ? 'active' : ''}`}
                onClick={() => changeLanguage('en')}
              >
                <Globe size={16} />
                <span>English</span>
              </button>
              <button 
                className={`settings-toggle-btn ${i18n.language === 'te' ? 'active' : ''}`}
                onClick={() => changeLanguage('te')}
              >
                <Globe size={16} />
                <span>తెలుగు</span>
              </button>
            </div>
          </div>
        </div>

        <div className="settings-footer">
          <p className="settings-version">iACLS v2.4.0 • Elite Edition</p>
        </div>
      </div>
    </div>
  );
};

export default SettingsPanel;
