import axios from 'axios';

const API_URL = '/api';

const api = axios.create({
  baseURL: API_URL,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  const lang = localStorage.getItem('i18nextLng') || 'en';
  
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  // Ensure the backend returns translated content based on the user's language selection
  config.headers['Accept-Language'] = lang;
  
  return config;
});

// Response interceptor to handle token expiration
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Check if the error is 401 and we haven't retried yet
    if (error.response && error.response.status === 401 && !originalRequest._retry) {
      // If the error is on login or refresh itself, don't try to refresh
      if (originalRequest.url === '/accounts/login/' || originalRequest.url === '/accounts/refresh/') {
        return Promise.reject(error);
      }

      originalRequest._retry = true;
      const refreshToken = localStorage.getItem('refresh_token');

      if (refreshToken) {
        try {
          // Attempt to get a new access token
          const res = await axios.post(`${API_URL}/accounts/refresh/`, { refresh: refreshToken });
          const newAccessToken = res.data.access;
          
          localStorage.setItem('access_token', newAccessToken);

          // Update the header and retry the original request
          originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
          return api(originalRequest);
        } catch (refreshError) {
          // If refresh also fails, logout the user
          localStorage.removeItem('access_token');
          localStorage.removeItem('refresh_token');
          window.location.href = '/login';
          return Promise.reject(refreshError);
        }
      } else {
        // No refresh token available
        window.location.href = '/login';
      }
    }

    return Promise.reject(error);
  }
);

// Accounts API
export const login = (email, password) => api.post('/accounts/login/', { email, password });
export const signup = (data) => api.post('/accounts/signup/', data);
export const getMe = () => api.get('/accounts/me/');

// ACLS Simulation API
export const getDashboard = () => api.get('/acls/dashboard/');
export const getStep = (stepId, tts = true) => api.get(`/acls/step/${stepId}/`, { params: { tts } });
export const getSpeechFromText = (text, lang) => api.post('/acls/tts-text/', { text, lang });

export default api;

