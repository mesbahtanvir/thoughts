import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { authAPI } from '../services/api';
import { 
  Container, 
  Typography, 
  Box, 
  Paper, 
  Button, 
  CircularProgress,
  Divider,
  Chip,
  Avatar
} from '@mui/material';
import { 
  Email as EmailIcon, 
  CheckCircle as CheckCircleIcon, 
  Cancel as CancelIcon,
  ArrowBack as ArrowBackIcon
} from '@mui/icons-material';

const Profile = () => {
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchUserProfile = async () => {
      try {
        setIsLoading(true);
        const userData = await authAPI.getCurrentUser();
        setUser(userData);
      } catch (err) {
        console.error('Failed to fetch user profile:', err);
        setError('Failed to load profile. Please try again.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchUserProfile();
  }, []);

  const handleLogout = () => {
    authAPI.logout();
    navigate('/login');
  };

  const handleResendVerification = async () => {
    // TODO: Implement resend verification email
    alert('Verification email resent! Please check your inbox.');
  };

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress />
      </Box>
    );
  }

  if (!user) {
    return (
      <Container maxWidth="sm" sx={{ mt: 4 }}>
        <Paper elevation={3} sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h6" color="error">
            {error || 'Failed to load user profile'}
          </Typography>
          <Button 
            variant="contained" 
            color="primary" 
            onClick={() => window.location.reload()}
            sx={{ mt: 2 }}
          >
            Retry
          </Button>
        </Paper>
      </Container>
    );
  }

  return (
    <Container maxWidth="sm" sx={{ mt: 4, mb: 4 }}>
      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate(-1)}
        sx={{ mb: 2 }}
      >
        Back
      </Button>
      
      <Paper elevation={3} sx={{ p: 4 }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 4 }}>
          <Avatar sx={{ width: 80, height: 80, mb: 2, bgcolor: 'primary.main' }}>
            {user.email.charAt(0).toUpperCase()}
          </Avatar>
          <Typography variant="h5" component="h1" gutterBottom>
            {user.email}
          </Typography>
          <Chip
            icon={user.email_verified ? <CheckCircleIcon /> : <CancelIcon />}
            label={user.email_verified ? 'Email Verified' : 'Email Not Verified'}
            color={user.email_verified ? 'success' : 'error'}
            variant="outlined"
            sx={{ mt: 1 }}
          />
        </Box>

        <Divider sx={{ my: 3 }} />

        <Box>
          <Typography variant="subtitle2" color="text.secondary">
            Member Since
          </Typography>
          <Typography variant="body1" gutterBottom>
            {new Date(user.created_at).toLocaleDateString()}
          </Typography>
        </Box>

        {!user.email_verified && (
          <Box mt={4} textAlign="center">
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Please verify your email address to unlock all features.
            </Typography>
            <Button
              variant="outlined"
              color="primary"
              onClick={handleResendVerification}
              sx={{ mt: 1 }}
            >
              Resend Verification Email
            </Button>
          </Box>
        )}

        <Box mt={4}>
          <Button
            fullWidth
            variant="contained"
            color="primary"
            onClick={() => navigate('/change-password')}
            sx={{ mb: 2 }}
          >
            Change Password
          </Button>
          <Button
            fullWidth
            variant="outlined"
            color="error"
            onClick={handleLogout}
          >
            Logout
          </Button>
        </Box>
      </Paper>
    </Container>
  );
};

export default Profile;
