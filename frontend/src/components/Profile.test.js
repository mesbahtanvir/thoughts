import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Profile from './Profile';
import { authAPI } from '../services/api';

// Mock the navigate function
const mockNavigate = jest.fn();

// Mock the API module
jest.mock('../services/api');

// Mock useNavigate
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useNavigate: () => mockNavigate,
}));

describe('Profile Component', () => {
  const mockUser = {
    id: 1,
    email: 'test@example.com',
    email_verified: true,
    created_at: '2023-05-18T12:00:00Z',
  };

  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
    
    // Mock the getCurrentUser function
    authAPI.getCurrentUser = jest.fn().mockResolvedValue(mockUser);
  });

  it('renders profile page with user data', async () => {
    render(
      <MemoryRouter>
        <Profile />
      </MemoryRouter>
    );

    // Check if loading spinner is shown initially
    expect(screen.getByRole('progressbar')).toBeInTheDocument();

    // Wait for the user data to be loaded
    await waitFor(() => {
      expect(screen.getByText(mockUser.email)).toBeInTheDocument();
      expect(screen.getByText('Email Verified')).toBeInTheDocument();
      expect(screen.getByText('Change Password')).toBeInTheDocument();
      expect(screen.getByText('Logout')).toBeInTheDocument();
    });
  });

  it('shows not verified message when email is not verified', async () => {
    // Mock unverified user
    authAPI.getCurrentUser = jest.fn().mockResolvedValue({
      ...mockUser,
      email_verified: false,
    });

    render(
      <MemoryRouter>
        <Profile />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByText('Email Not Verified')).toBeInTheDocument();
      expect(screen.getByText('Resend Verification Email')).toBeInTheDocument();
    });
  });

  it('handles API error', async () => {
    // Mock API error
    authAPI.getCurrentUser = jest.fn().mockRejectedValue(new Error('API Error'));
    
    // Mock console.error to avoid error logs in test output
    const originalError = console.error;
    console.error = jest.fn();

    render(
      <MemoryRouter>
        <Profile />
      </MemoryRouter>
    );

    // Should show error message
    await waitFor(() => {
      expect(screen.getByText('Failed to load profile. Please try again.')).toBeInTheDocument();
    });

    // Restore console.error
    console.error = originalError;
  });
});
