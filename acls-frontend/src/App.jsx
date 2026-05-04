import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useState, useEffect, Suspense, lazy } from 'react';
import LoadingSpinner from './components/LoadingSpinner';
import { getMe, logout } from './services/api';
import { useTheme } from './hooks/useTheme';

// Lazy load components for code splitting
const Login = lazy(() => import('./components/Login'));
const Signup = lazy(() => import('./components/Signup'));
const Dashboard = lazy(() => import('./components/Dashboard'));
const ACLSWorkflow = lazy(() => import('./components/ACLSWorkflow'));

function App() {
  const { t } = useTranslation();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const { theme, toggleTheme } = useTheme();

  useEffect(() => {
    let timeout;
    const resetTimer = () => {
      if (timeout) clearTimeout(timeout);
      // Logout after 30 minutes of inactivity (1800000 ms)
      timeout = setTimeout(async () => {
        if (localStorage.getItem('access_token') || sessionStorage.getItem('access_token')) {
          try {
            await logout();
          } catch (err) {
            console.error('Logout on inactivity failed', err);
          }
          localStorage.removeItem('access_token');
          sessionStorage.removeItem('access_token');
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

    if (localStorage.getItem('access_token') || sessionStorage.getItem('access_token')) {
      fetchUser();
    } else {
      setLoading(false);
    }

    return () => clearTimeout(timeout);
  }, []);

  if (loading) return <LoadingSpinner fullScreen message={t('loading_app') || "Loading Application"} />;

  return (
    <Router>
      {/* Global Application Layout */}
      <div style={{ position: 'relative', width: '100%', minHeight: '100vh', overflow: 'auto', background: 'var(--bg-main)', transition: 'background 0.3s ease' }}>

        <style>{`
          @media (prefers-reduced-motion: reduce) {
            .ecg-scroll-global {
              animation: none !important;
            }
          }
        `}</style>

        {/* Clean background */}

        {/* Global Foreground Scrolling Content */}
        <div style={{ position: 'relative', width: '100%', height: '100%', overflowY: 'auto', overflowX: 'hidden', zIndex: 10 }}>
          <Suspense fallback={<LoadingSpinner fullScreen message={t('loading') || "Loading..."} />}>
            <Routes>
              <Route path="/login" element={!user ? <Login onLogin={setUser} theme={theme} toggleTheme={toggleTheme} /> : <Navigate to="/dashboard" />} />
              <Route path="/signup" element={!user ? <Signup theme={theme} toggleTheme={toggleTheme} /> : <Navigate to="/dashboard" />} />
              <Route path="/dashboard" element={user ? <Dashboard user={user} setUser={setUser} theme={theme} toggleTheme={toggleTheme} /> : <Navigate to="/login" />} />
              <Route path="/acls/*" element={user ? <ACLSWorkflow user={user} setUser={setUser} theme={theme} toggleTheme={toggleTheme} /> : <Navigate to="/login" />} />
              <Route path="/" element={!user ? <Login onLogin={setUser} theme={theme} toggleTheme={toggleTheme} /> : <Navigate to="/dashboard" />} />
            </Routes>
          </Suspense>
        </div>
        <Toaster 
          position="top-right" 
          reverseOrder={false}
          toastOptions={{
            duration: 4000,
            style: {
              background: 'rgba(255, 255, 255, 0.95)',
              backdropFilter: 'blur(12px)',
              WebkitBackdropFilter: 'blur(12px)',
              color: '#0F172A',
              padding: '16px 24px',
              borderRadius: '20px',
              fontSize: '15px',
              fontWeight: '700',
              boxShadow: '0 20px 40px rgba(0,0,0,0.1)',
              border: '1px solid rgba(255, 255, 255, 0.5)',
            },
            success: {
              iconTheme: {
                primary: '#005B41',
                secondary: '#fff',
              },
              style: {
                borderLeft: '5px solid #005B41',
              }
            },
            error: {
              iconTheme: {
                primary: '#ef4444',
                secondary: '#fff',
              },
              style: {
                borderLeft: '5px solid #ef4444',
              }
            }
          }}
        />
      </div>
    </Router>
  );
}

export default App;

