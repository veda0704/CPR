import React from 'react';

// --- Theme-Aware Confetti Component ---
const Confetti = () => {
  // We use CSS variables to make it theme-aware
  const particles = Array.from({ length: 70 }, (_, i) => ({
    id: i,
    left: `${Math.random() * 100}%`,
    delay: `${Math.random() * 2}s`,
    duration: `${3 + Math.random() * 2}s`,
    size: `${6 + Math.random() * 10}px`,
    shape: Math.random() > 0.5 ? 'circle' : 'square',
    rotation: `${Math.random() * 360}deg`,
    // Distribute colors between primary, primary-soft, and some accent colors
    opacity: 0.4 + Math.random() * 0.6,
    drift: `${(Math.random() - 0.5) * 200}px`,
  }));

  return (
    <div className="confetti-container" aria-hidden="true">
      {particles.map(p => (
        <div
          key={p.id}
          className="confetti-particle"
          style={{
            left: p.left,
            animationDelay: p.delay,
            animationDuration: p.duration,
            width: p.size,
            height: p.size,
            // Use color-mix to create dynamic theme-based particles
            background: p.id % 3 === 0 
              ? 'var(--primary-color)' 
              : p.id % 3 === 1 
                ? 'color-mix(in srgb, var(--primary-color), white 40%)' 
                : 'color-mix(in srgb, var(--primary-color), black 20%)',
            borderRadius: p.shape === 'circle' ? '50%' : '2px',
            opacity: p.opacity,
            '--drift': p.drift,
            '--rotation': p.rotation,
          }}
        />
      ))}
    </div>
  );
};

export default Confetti;