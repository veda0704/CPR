const STORAGE_KEY = 'acls_module_status';

const safeParse = (value) => {
  try {
    return JSON.parse(value) || {};
  } catch {
    return {};
  }
};

const getStoredStatuses = (userId) => {
  if (typeof localStorage === 'undefined' || !userId) return {};
  const key = `${STORAGE_KEY}_${userId}`;
  return safeParse(localStorage.getItem(key));
};

const setStoredStatuses = (userId, statuses) => {
  if (typeof localStorage === 'undefined' || !userId) return;
  const key = `${STORAGE_KEY}_${userId}`;
  localStorage.setItem(key, JSON.stringify(statuses));
};

export const STATUS_LABELS = {
  not_started: 'Not Started',
  in_progress: 'In Progress',
  completed: 'Completed',
};

export const STATUS_COLORS = {
  not_started: 'var(--muted)',
  in_progress: 'var(--orange)',
  completed: 'var(--sage)',
};

export const getModuleStatus = (moduleId, userId) => {
  if (!moduleId || !userId) return 'not_started';
  const statuses = getStoredStatuses(userId);
  const data = statuses[moduleId];
  if (!data) return 'not_started';
  if (typeof data === 'string') return data; // Backward compatibility
  return data.status || 'not_started';
};

export const setModuleStatus = (moduleId, status, userId) => {
  if (!moduleId || !userId) return;
  const statuses = getStoredStatuses(userId);
  let current = statuses[moduleId] || { status: 'not_started', progress: 0 };
  
  // Convert legacy string to object if needed
  if (typeof current === 'string') {
    current = { status: current, progress: current === 'completed' ? 100 : 0 };
  }
  
  if (current.status === 'completed' && status === 'in_progress') return;
  
  statuses[moduleId] = { 
    ...current,
    status,
    lastAccessed: new Date().toISOString()
  };
  if (status === 'completed') statuses[moduleId].progress = 100;
  
  setStoredStatuses(userId, statuses);
};

export const getModuleProgress = (moduleId, userId) => {
  if (!moduleId || !userId) return 0;
  const statuses = getStoredStatuses(userId);
  const data = statuses[moduleId];
  if (!data) return 0;
  if (typeof data === 'string') return data === 'completed' ? 100 : 0; // Backward compatibility
  return data.progress || 0;
};

export const setModuleProgress = (moduleId, progress, userId) => {
  if (!moduleId || !userId) return;
  const statuses = getStoredStatuses(userId);
  let current = statuses[moduleId] || { status: 'in_progress', progress: 0 };
  
  // Convert legacy string to object if needed
  if (typeof current === 'string') {
    current = { status: current, progress: current === 'completed' ? 100 : 0 };
  }
  
  // Don't downgrade from 100%
  if (current.progress === 100 && progress < 100) return;
  
  statuses[moduleId] = {
    ...current,
    progress: Math.max(current.progress, progress),
    lastAccessed: new Date().toISOString()
  };
  
  if (progress >= 100) statuses[moduleId].status = 'completed';
  else if (progress > 0) statuses[moduleId].status = 'in_progress';
  
  setStoredStatuses(userId, statuses);
};

export const getStatusLabel = (status) => STATUS_LABELS[status] || STATUS_LABELS.not_started;
export const getStatusColor = (status) => STATUS_COLORS[status] || STATUS_COLORS.not_started;

export const getAllModuleStatuses = (userId) => getStoredStatuses(userId);
