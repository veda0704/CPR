import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Import English Locales
import enCommon from './locales/en/common';
import enBls from './locales/en/bls';
import enAirway from './locales/en/airway';
import enCardiac from './locales/en/cardiac';
import enStroke from './locales/en/stroke';
import enAcs from './locales/en/acs';
import enSpecial from './locales/en/special';

// Import Telugu Locales
import teCommon from './locales/te/common';
import teBls from './locales/te/bls';
import teAirway from './locales/te/airway';
import teCardiac from './locales/te/cardiac';
import teStroke from './locales/te/stroke';
import teAcs from './locales/te/acs';
import teSpecial from './locales/te/special';

const resources = {
  en: {
    translation: {
      ...enCommon,
      ...enBls,
      ...enAirway,
      ...enCardiac,
      ...enStroke,
      ...enAcs,
      ...enSpecial
    },
  },
  te: {
    translation: {
      ...teCommon,
      ...teBls,
      ...teAirway,
      ...teCardiac,
      ...teStroke,
      ...teAcs,
      ...teSpecial
    },
  }
};

const savedLanguage = localStorage.getItem('i18nextLng') || 'en';

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: savedLanguage,
    fallbackLng: 'en',
    keySeparator: false,
    nsSeparator: false,
    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;
