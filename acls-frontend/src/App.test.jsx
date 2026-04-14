import { render, screen, waitFor } from '@testing-library/react';
import App from './App';
import { describe, beforeEach, it, expect, vi } from 'vitest';

vi.mock('./services/api', () => ({
  getMe: vi.fn(),
}));

vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key) => key,
    i18n: { language: 'en', changeLanguage: vi.fn() },
  }),
}));

describe('App', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('renders login screen when no user token exists', async () => {
    render(<App />);

    await waitFor(() => {
      expect(screen.getByText('EN')).toBeTruthy();
      expect(screen.getByText('తెలుగు')).toBeTruthy();
    });
  });
});
