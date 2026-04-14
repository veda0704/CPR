import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Dashboard from './Dashboard';
import * as api from '../services/api';
import { describe, beforeEach, it, expect, vi } from 'vitest';

vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key) => key,
    i18n: { language: 'en', changeLanguage: vi.fn() },
  }),
}));

vi.mock('../services/api', () => ({
  getDashboard: vi.fn(),
}));

describe('Dashboard', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    localStorage.clear();
  });

  it('renders dashboard modules from API data', async () => {
    api.getDashboard.mockResolvedValue({
      data: {
        levels: [
          {
            id: 'level1',
            name: 'Level 1',
            description: 'Description for level 1',
            tag: 'NEW',
            modules: [
              {
                id: 'scene_safety',
                start_step: 'scene_safety_start',
                name: 'scene_safety',
                description: 'scene_safety_desc',
              },
            ],
          },
        ],
        modes: ['Training'],
      },
    });

    render(
      <MemoryRouter>
        <Dashboard user={{ username: 'tester' }} setUser={vi.fn()} />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(api.getDashboard).toHaveBeenCalledTimes(1);
      expect(screen.getByText('Level 1')).toBeInTheDocument();
      expect(screen.getByText('scene_safety')).toBeInTheDocument();
      expect(screen.getByText('scene_safety_desc')).toBeInTheDocument();
      expect(screen.queryByText('Training')).not.toBeInTheDocument();
      expect(screen.queryByText('View History')).not.toBeInTheDocument();
      expect(screen.getByText('Not Started')).toBeInTheDocument();
    });
  });
});
