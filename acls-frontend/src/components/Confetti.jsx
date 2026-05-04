import React from 'react';

// --- Confetti Particle Component ---
const colors = ['#0284C7', '#0F172A', '#38BDF8', '#10B981', '#60A5FA', '#1E293B', '#BAE6FD'];
const particles = Array.from({ length: 60 }, (_, i) => ({
  id: i,
  color: colors[i % colors.length],
  left: `${Math.random() * 100}%`,
  delay: `${Math.random() * 1.5}s`,
  duration: `${2.5 + Math.random() * 2}s`,
  size: `${6 + Math.random() * 8}px`,
  shape: Math.random() > 0.5 ? 'circle' : 'square',
  rotation: `${Math.random() * 360}deg`,
}));

const Confetti = () => {
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
            background: p.color,
            borderRadius: p.shape === 'circle' ? '50%' : '2px',
            transform: `rotate(${p.rotation})`,
          }}
        />
      ))}
    </div>
  );
};

export default Confetti;