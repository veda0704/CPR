import React from 'react';
import { HeartPulse } from 'lucide-react';
import './LoadingSpinner.css';

const LoadingSpinner = ({ fullScreen = true, message = 'Initializing Scenario...' }) => {
  return (
    <div className={fullScreen ? "loading-spinner-fullscreen" : "loading-spinner-inline"}>
      <div className="loading-spinner-container">
        <div className="spinner-animation">
          <div className="pulse-ring"></div>
          <div className="pulse-ring pulse-ring-2"></div>
          <div className="spinner-center">
            <HeartPulse size={44} color="#81C784" fill="#81C784" strokeWidth={1.5} />
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
};

export default LoadingSpinner;
