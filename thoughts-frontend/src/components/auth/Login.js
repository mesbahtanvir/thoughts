import React, { useState } from 'react';
import { authAPI } from '../../services/api';
import {
  Box,
  Button,
  Container,
  TextField,
  Typography,
  Link,
  Divider,
  InputAdornment,
  IconButton
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { Email as EmailIcon, Lock as LockIcon, Visibility, VisibilityOff } from '@mui/icons-material';

const Login = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleClickShowPassword = () => setShowPassword((show) => !show);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    
    try {
      // Show loading state
      setError({ message: 'Logging in...', type: 'info' });
      
      // Call the login API
      const { token, user } = await authAPI.login(formData.email, formData.password);
      
      if (!token || !user) {
        throw new Error('Login successful but no user data received');
      }
      
      // Get the redirect path from the URL or default to '/home'
      const from = new URLSearchParams(window.location.search).get('from') || '/home';
      
      // Use replace: true to prevent going back to the login page with the back button
      navigate(from, { replace: true });
    } catch (err) {
      console.error('Login error:', err);
      setError({ 
        message: err.message || 'Login failed. Please check your credentials and try again.',
        type: 'error' 
      });
    }
  };

  return (
    <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', bgcolor: '#f5f5f5' }}>
      <Container maxWidth="xs">
        <Box sx={{ textAlign: 'center', mb: 4 }}>
          <Typography variant="h5" component="h1" sx={{ fontWeight: 500, mb: 1 }}>
            Welcome back
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Sign in to continue
          </Typography>
        </Box>

        <Box 
          component="form" 
          onSubmit={handleSubmit}
          sx={{ 
            bgcolor: 'background.paper',
            p: 3,
            borderRadius: 2,
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)'
          }}
        >
          <TextField
            fullWidth
            margin="normal"
            placeholder="Email address"
            name="email"
            type="email"
            autoComplete="email"
            value={formData.email}
            onChange={handleChange}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <EmailIcon color="action" />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
          />
          
          <TextField
            fullWidth
            margin="normal"
            placeholder="Password"
            name="password"
            type={showPassword ? 'text' : 'password'}
            autoComplete="current-password"
            value={formData.password}
            onChange={handleChange}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <LockIcon color="action" />
                </InputAdornment>
              ),
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton
                    aria-label="toggle password visibility"
                    onClick={handleClickShowPassword}
                    edge="end"
                    size="small"
                  >
                    {showPassword ? <VisibilityOff /> : <Visibility />}
                  </IconButton>
                </InputAdornment>
              ),
            }}
          />

          <Button
            type="submit"
            fullWidth
            variant="contained"
            size="large"
            sx={{
              mt: 3,
              py: 1.5,
              textTransform: 'none',
              fontWeight: 500,
              borderRadius: 2
            }}
          >
            Sign in
          </Button>

          {error && (
            <Typography 
              color={error.type === 'error' ? 'error' : 'primary'} 
              sx={{ mb: 2, textAlign: 'center' }}
            >
              {error.message}
            </Typography>
          )}

          <Divider sx={{ my: 3 }} />
          
          <Box sx={{ textAlign: 'center' }}>
            <Typography variant="body2" color="text.secondary">
              Don't have an account?{' '}
              <Link href="/register" color="primary" underline="hover" sx={{ fontWeight: 500 }}>
                Sign up
              </Link>
            </Typography>
          </Box>
        </Box>
      </Container>
    </Box>
  );
};

export default Login;
