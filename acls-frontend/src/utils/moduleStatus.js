const STORAGE_KEY = 'acls_module_status';

const safeParse = (value) => {
  try {
    return JSON.parse(value) || {};
  } catch {
    return {};
  }
};

const getStoredStatuses = () => {
  if (typeof localStorage === 'undefined') return {};
  return safeParse(localStorage.getItem(STORAGE_KEY));
};

const setStoredStatuses = (statuses) => {
  if (typeof localStorage === 'undefined') return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(statuses));
};

export const STATUS_LABELS = {
  not_started: 'Not Started',
  in_progress: 'In Progress',
  completed: 'Completed',
};

export const STATUS_COLORS = {
  not_started: '#9ca3af',
  in_progress: '#f59e0b',
  completed: '#16a34a',
};

export const getModuleStatus = (moduleId) => {
  if (!moduleId) return 'not_started';
  const statuses = getStoredStatuses();
  return statuses[moduleId] || 'not_started';
};

export const setModuleStatus = (moduleId, status) => {
  if (!moduleId) return;
  const statuses = getStoredStatuses();
  const currentStatus = statuses[moduleId];
  if (currentStatus === 'completed' && status === 'in_progress') return;
  statuses[moduleId] = status;
  setStoredStatuses(statuses);
};

export const getStatusLabel = (status) => STATUS_LABELS[status] || STATUS_LABELS.not_started;
export const getStatusColor = (status) => STATUS_COLORS[status] || STATUS_COLORS.not_started;
