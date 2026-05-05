import React from 'react';
import { useTranslation } from 'react-i18next';
import { X, Moon, Sun, Globe, Palette, Check } from 'lucide-react';
import { applyTheme } from '../utils/theme';

const themes = {
  maroon: "#8B0000",
  orange: "#F57C00",
  brown: "#6D4C41",
  teal: "#355E63",
  emerald: "#005B41", // Original green preserved as an option
  navy: "#1E3A8A",
  purple: "#6D28D9"
};

const SettingsPanel = ({ isOpen, onClose, theme, toggleTheme }) => {
  const { t, i18n } = useTranslation();
  const currentThemeColor = localStorage.getItem('themeColor') || '#005B41';

  if (!isOpen) return null;

  const handleColorSelect = (color) => {
    applyTheme(color);
    onClose();
  };

  const handleLanguageToggle = () => {
    const next = i18n.language === 'en' ? 'te' : 'en';
    i18n.changeLanguage(next);
    localStorage.setItem('i18nextLng', next);
  };

  return (
    <div className="settings-overlay animate-reveal" onClick={onClose}>
      <div className="settings-panel animate-reveal" onClick={e => e.stopPropagation()}>
        <div className="settings-header">
          <div className="settings-title">
            <Palette size={20} className="text-primary" />
            <span>{t('settings') || 'Settings'}</span>
          </div>
          <button className="settings-close" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        <div className="settings-content">
          {/* Theme Color Selection */}
          <div className="settings-section">
            <label className="settings-label">{t('theme_color') || 'Theme Color'}</label>
            <div className="theme-grid">
              {Object.entries(themes).map(([name, color]) => (
                <button
                  key={name}
                  className={`theme-color-btn ${currentThemeColor === color ? 'active' : ''}`}
                  style={{ backgroundColor: color }}
                  onClick={() => handleColorSelect(color)}
                  title={name}
                >
                  {currentThemeColor === color && <Check size={16} color="white" />}
                </button>
              ))}
            </div>
          </div>

          {/* Dark / Light Mode */}
          <div className="settings-section">
            <label className="settings-label">{t('appearance') || 'Appearance'}</label>
            <button className="settings-toggle-btn" onClick={toggleTheme}>
              {theme === 'dark' ? (
                <><Sun size={18} /> <span>{t('light_mode') || 'Light Mode'}</span></>
              ) : (
                <><Moon size={18} /> <span>{t('dark_mode') || 'Dark Mode'}</span></>
              )}
            </button>
          </div>

          {/* Language Toggle */}
          <div className="settings-section">
            <label className="settings-label">{t('language') || 'Language'}</label>
            <button className="settings-toggle-btn" onClick={handleLanguageToggle}>
              <Globe size={18} />
              <span>{i18n.language === 'en' ? 'తెలుగు (Telugu)' : 'English'}</span>
            </button>
          </div>
        </div>

        <div className="settings-footer">
          <p className="settings-hint">{t('settings_hint') || 'Preferences apply instantly and persist across sessions.'}</p>
        </div>
      </div>
    </div>
  );
};

export default SettingsPanel;
