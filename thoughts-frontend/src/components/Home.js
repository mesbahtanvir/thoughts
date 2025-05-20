import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { authAPI, thoughtsAPI } from '../services/api';
import { 
  AppBar,
  Toolbar,
  IconButton,
  Typography, 
  Box, 
  TextField, 
  Paper,
  Container,
  Avatar,
  Divider,
  Button
  // CircularProgress removed as it's unused
} from '@mui/material';
import { 
  Logout as LogoutIcon,
  Delete as DeleteIcon,
  AccountCircle as AccountCircleIcon,
} from '@mui/icons-material';

const Home = () => {
  const navigate = useNavigate();
  const [thought, setThought] = useState('');
  const [thoughts, setThoughts] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  // Using eslint-disable on next line as error state is set but not directly used in UI
  // eslint-disable-next-line no-unused-vars
  const [error, setError] = useState(null);
  const [currentUser, setCurrentUser] = useState(null);

  // Fetch user profile and thoughts on component mount
  useEffect(() => {
    const fetchData = async () => {
      try {
        setIsLoading(true);
        // Fetch user profile
        const user = await authAPI.getCurrentUser();
        setCurrentUser(user);
        
        // Fetch thoughts
        const data = await thoughtsAPI.getThoughts();
        setThoughts(data);
      } catch (err) {
        console.error('Failed to fetch data:', err);
        setError('Failed to load data');
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleLogout = () => {
    authAPI.logout();
    navigate('/login');
  };

  const handleShareThought = async (e) => {
    e.preventDefault();
    if (!thought.trim()) return;
    
    try {
      setIsLoading(true);
      const response = await thoughtsAPI.createThought(thought);
      // The backend returns the created thought with id and created_at
      setThoughts([{
        id: response.id,
        content: thought,
        created_at: new Date().toISOString()
      }, ...thoughts]);
      setThought('');
    } catch (err) {
      console.error('Failed to create thought:', err);
      setError(err.message || 'Failed to post thought');
      
      // If unauthorized, redirect to login
      if (err.message.includes('401')) {
        navigate('/login');
      }
    } finally {
      setIsLoading(false);
    }
  };
  
  const handleDeleteThought = async (id) => {
    try {
      await thoughtsAPI.deleteThought(id);
      setThoughts(thoughts.filter(t => t.id !== id));
    } catch (err) {
      console.error('Failed to delete thought:', err);
      setError('Failed to delete thought');
    }
  };

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh', bgcolor: '#f5f5f5' }}>
      <AppBar position="static" color="transparent" elevation={0}>
        <Container maxWidth="md">
          <AppBar position="static" color="default" elevation={1}>
            <Toolbar>
              <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                Thoughts
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center' }}>
                <IconButton 
                  color="inherit" 
                  onClick={() => navigate('/profile')}
                  sx={{ mr: 1 }}
                  title="Profile"
                >
                  {currentUser?.email_verified ? (
                    <Avatar sx={{ width: 32, height: 32, bgcolor: 'primary.main' }}>
                      {currentUser.email.charAt(0).toUpperCase()}
                    </Avatar>
                  ) : (
                    <AccountCircleIcon />
                  )}
                </IconButton>
                <IconButton color="inherit" onClick={handleLogout} title="Logout">
                  <LogoutIcon />
                </IconButton>
              </Box>
            </Toolbar>
          </AppBar>
        </Container>
      </AppBar>
      <Divider />

        <Container maxWidth="md" sx={{ flex: 1, py: 3, px: { xs: 2, sm: 3 } }}>
          <Box sx={{ mb: 4, textAlign: 'center' }}>
            <Typography variant="h5" component="h1" gutterBottom sx={{ fontWeight: 500, mb: 1 }}>
              Welcome
            </Typography>
            <Typography variant="body1" color="text.secondary">
              Share your thoughts...
            </Typography>
          </Box>

          {/* Thoughts List */}
          <Box sx={{ maxWidth: 600, mx: 'auto' }}>
            {thoughts.map((item) => (
              <Paper 
                key={item.id} 
                elevation={0} 
                sx={{ 
                  p: 2, 
                  mb: 2, 
                  bgcolor: 'background.paper',
                  borderRadius: 2,
                  border: '1px solid',
                  borderColor: 'divider',
                  position: 'relative',
                  '&:hover': {
                    '& .delete-button': {
                      opacity: 1,
                    }
                  }
                }}
              >
                <Typography variant="body1">{item.content}</Typography>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 1 }}>
                  <Typography variant="caption" color="text.secondary">
                    {new Date(item.created_at).toLocaleString()}
                  </Typography>
                  <IconButton 
                    size="small" 
                    className="delete-button"
                    onClick={() => handleDeleteThought(item.id)}
                    sx={{ 
                      opacity: 0, 
                      transition: 'opacity 0.2s',
                      '&:hover': {
                        color: 'error.main'
                      }
                    }}
                  >
                    <DeleteIcon fontSize="small" />
                  </IconButton>
                </Box>
              </Paper>
            ))}
          </Box>
        </Container>

        <Box sx={{ mt: 'auto', py: 3, px: { xs: 2, sm: 0 } }}>
          <Container maxWidth="sm">
            <Box component="form" onSubmit={handleShareThought} sx={{ display: 'flex', gap: 1, mt: 2, mb: 4 }}>
              <TextField
                fullWidth
                variant="outlined"
                placeholder="What's on your mind?"
                value={thought}
                onChange={(e) => setThought(e.target.value)}
                size="small"
                disabled={isLoading}
                sx={{ 
                  '& .MuiOutlinedInput-root': { 
                    borderRadius: 2,
                    bgcolor: 'background.paper'
                  }
                }}
              />
              <Button 
                type="submit" 
                variant="contained" 
                color="primary"
                disabled={isLoading || !thought.trim()}
                sx={{ borderRadius: 2, minWidth: 100 }}
              >
                {isLoading ? 'Sharing...' : 'Share'}
              </Button>
            </Box>
          </Container>
        </Box>
    </Box>
  );
};

export default Home;
