import React from 'react';
import { CheckCircle, AlertTriangle, ChevronRight } from 'lucide-react';

// --- Premium Choice Cards Component ---
const ChoiceCards = ({ options, onSelect }) => {
  return (
    <div className="choice-cards-grid">
      {options.map((opt, idx) => (
        <div key={idx} className="choice-card" onClick={() => onSelect(opt.next, opt)}>
          {/* Image on Top */}
          <div className="choice-card-image-box">
            <img src={opt.image} alt={opt.label} />
          </div>

          <div className="choice-card-body">
            {/* Title Below Image */}
            <h2 className="choice-card-title">{opt.label}</h2>
            {/* Age Description Below Title */}
            <p className="choice-card-desc">{opt.description}</p>

            {/* Full Width CTA Button at Bottom */}
            <button className="choice-card-btn">
              <span>{opt.action_label || `SELECT ${opt.label}`.toUpperCase()}</span>
              <ChevronRight size={22} strokeWidth={3} />
            </button>
          </div>
        </div>
      ))}
    </div>
  );
};

export default ChoiceCards;