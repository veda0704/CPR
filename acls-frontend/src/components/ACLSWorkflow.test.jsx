import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import ACLSWorkflow from './ACLSWorkflow';
import * as api from '../services/api';
import { describe, beforeAll, beforeEach, it, expect, vi } from 'vitest';

vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key) => key,
    i18n: { language: 'en', changeLanguage: vi.fn() },
  }),
}));

vi.mock('../services/api', () => ({
  getStep: vi.fn(),
}));

vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key) => key,
    i18n: { language: 'en', changeLanguage: vi.fn() },
  }),
}));

describe('ACLSWorkflow', () => {
  beforeAll(() => {
    window.scrollTo = vi.fn();
  });

  beforeEach(() => {
    vi.clearAllMocks();
    localStorage.clear();
  });

  it('loads a step and shows a completion overlay when the final choice is selected', async () => {
    api.getStep.mockResolvedValue({
      data: {
        id: 'scene_safety_start',
        title: 'Scene Safety Start',
        question: 'Is the area safe?',
        choices: [
          { label: 'Continue', next: 'dashboard' },
        ],
        video: null,
        audio_url: null,
      },
    });

    render(
      <MemoryRouter initialEntries={['/acls/scene_safety_start']}>
        <Routes>
          <Route path="/acls/*" element={<ACLSWorkflow />} />
        </Routes>
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(api.getStep).toHaveBeenCalledWith('scene_safety_start');
      expect(screen.getByText('Scene Safety Start')).toBeInTheDocument();
      expect(screen.getByText('Is the area safe?')).toBeInTheDocument();
      expect(screen.getByText('Continue')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByText('Continue'));

    await waitFor(() => {
      expect(screen.getByText('Back to Dashboard')).toBeInTheDocument();
    });
  });
});
