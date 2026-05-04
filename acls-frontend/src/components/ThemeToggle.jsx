import React from 'react';

const ThemeToggle = ({ theme, toggleTheme, className = '', style = {} }) => (
  <button
    onClick={toggleTheme}
    className={`theme-toggle-btn ${className}`}
    title={theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
    aria-label="Toggle theme"
    style={style}
  >
    {theme === 'dark' ? '☀️' : '🌙'}
  </button>
);

export default ThemeToggle;
