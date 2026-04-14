import React from 'react';
import { HeartPulse } from 'lucide-react';
import './LoadingSpinner.css';

const LoadingSpinner = ({ fullScreen = false, message = 'Loading' }) => {
  if (fullScreen) {
    return (
      <div className="loading-spinner-fullscreen">
        <div className="loading-spinner-container">
          <div className="spinner-animation">
            <div className="pulse-ring"></div>
            <div className="pulse-ring pulse-ring-2"></div>
            <div className="pulse-ring pulse-ring-3"></div>
            <div className="spinner-center">
              <HeartPulse size={40} color="#ea580c" fill="#ea580c" />
            </div>
          </div>
          <div className="loading-text">
            <p className="loading-message">{message}</p>
            <div className="loading-dots">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="loading-spinner-inline">
      <div className="spinner-animation-small">
        <div className="pulse-ring-small"></div>
        <div className="pulse-ring-small pulse-ring-small-2"></div>
        <div className="spinner-center-small">
          <HeartPulse size={24} color="#ea580c" fill="#ea580c" />
        </div>
      </div>
      {message && <span className="loading-text-small">{message}</span>}
    </div>
  );
};

export default LoadingSpinner;
