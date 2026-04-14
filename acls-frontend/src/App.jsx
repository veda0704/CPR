import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useState, useEffect } from 'react';
import LoadingSpinner from './components/LoadingSpinner';
import Login from './components/Login';
import Signup from './components/Signup';
import Dashboard from './components/Dashboard';
import ACLSWorkflow from './components/ACLSWorkflow';
import { getMe } from './services/api';

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let timeout;
    const resetTimer = () => {
      if (timeout) clearTimeout(timeout);
      // Logout after 30 minutes of inactivity (1800000 ms)
      timeout = setTimeout(() => {
        if (localStorage.getItem('access_token')) {
          localStorage.removeItem('access_token');
          localStorage.removeItem('refresh_token');
          setUser(null);
        }
      }, 1800000); 
    };

    if (user) {
      window.addEventListener('mousemove', resetTimer);
      window.addEventListener('keydown', resetTimer);
      window.addEventListener('click', resetTimer);
      window.addEventListener('scroll', resetTimer);
      resetTimer();
    }

    return () => {
      window.removeEventListener('mousemove', resetTimer);
      window.removeEventListener('keydown', resetTimer);
      window.removeEventListener('click', resetTimer);
      window.removeEventListener('scroll', resetTimer);
      if (timeout) clearTimeout(timeout);
    };
  }, [user]);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const res = await getMe();
        setUser(res.data);
      } catch {
        setUser(null);
      } finally {
        setLoading(false);
      }
    };
    
    // Add timeout to prevent infinite loading
    const timeout = setTimeout(() => {
      setLoading(false);
    }, 10000); // 10 second timeout
    
    if (localStorage.getItem('access_token')) {
      fetchUser();
    } else {
      setLoading(false);
    }
    
    return () => clearTimeout(timeout);
  }, []);

  if (loading) return <LoadingSpinner fullScreen message="Loading Application" />;

  return (
    <Router>
      {/* Global Application Layout */}
      <div style={{ position: 'relative', width: '100%', height: '100vh', overflow: 'hidden', background: '#fff7ed' }}>

        <style>{`
          @keyframes ecgScrollGlobal {
            0% { transform: translateX(0); }
            100% { transform: translateX(-400px); }
          }
        `}</style>

        {/* Global Fixed Background (Orbs + Animated ECG) */}
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, zIndex: 0, pointerEvents: 'none' }}>
          <div style={{ position: 'absolute', top: '-10%', left: '-10%', width: '50vw', height: '50vw', background: '#ea580c', filter: 'blur(120px)', opacity: 0.15 }} />
          <div style={{ position: 'absolute', bottom: '-20%', right: '-10%', width: '60vw', height: '60vw', background: '#ef4444', filter: 'blur(140px)', opacity: 0.1 }} />
          <div style={{ position: 'absolute', top: '30%', right: '20%', width: '40vw', height: '40vw', background: '#f59e0b', filter: 'blur(100px)', opacity: 0.15 }} />

          <div style={{
            position: 'absolute', top: '50%', left: 0, width: 'calc(100vw + 400px)', height: '150px',
            marginTop: '-75px', animation: 'ecgScrollGlobal 3s linear infinite',
            filter: 'blur(3px)', opacity: 0.5
          }}>
            <svg width="100%" height="100%">
              <pattern id="ecg-pattern-global" x="0" y="0" width="400" height="150" patternUnits="userSpaceOnUse">
                <path d="M0 75 L 280 75 L 290 65 L 300 75 L 310 75 L 320 90 L 335 10 L 350 120 L 360 75 L 370 75 L 380 55 L 390 75 L 400 75"
                  fill="none" stroke="#ea580c" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round"
                  style={{ filter: 'drop-shadow(0 0 8px rgba(234,88,12,0.5))' }} />
              </pattern>
              <rect x="0" y="0" width="100%" height="100%" fill="url(#ecg-pattern-global)" />
            </svg>
          </div>
        </div>

        {/* Global Foreground Scrolling Content */}
        <div style={{ position: 'relative', width: '100%', height: '100%', overflowY: 'auto', overflowX: 'hidden', zIndex: 10 }}>
          <Routes>
            <Route path="/login" element={!user ? <Login onLogin={setUser} /> : <Navigate to="/dashboard" />} />
            <Route path="/signup" element={!user ? <Signup /> : <Navigate to="/dashboard" />} />
            <Route path="/dashboard" element={user ? <Dashboard user={user} setUser={setUser} /> : <Navigate to="/login" />} />
            <Route path="/acls/*" element={user ? <ACLSWorkflow /> : <Navigate to="/login" />} />
            <Route path="/" element={!user ? <Login onLogin={setUser} /> : <Navigate to="/dashboard" />} />
          </Routes>
        </div>
        <Toaster position="top-center" reverseOrder={false} />
      </div>
    </Router>
  );
}

export default App;

