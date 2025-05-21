// Get API URL from environment variable or use localhost as fallback
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api'; // Include /api in the base URL
console.log('Using API URL:', API_BASE_URL);

// Helper function to handle API requests
const apiRequest = async (endpoint, options = {}) => {
  const token = localStorage.getItem('token');
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
    console.log('Using token:', token);
  } else {
    console.log('No token found in localStorage');
  }

  try {
    console.log(`Making ${options.method || 'GET'} request to ${API_BASE_URL}${endpoint}`);
    console.log('Request headers:', headers);
    if (options.body) {
      console.log('Request body:', options.body);
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers,
      body: options.body ? JSON.stringify(options.body) : undefined,
    });

    let data;
    try {
      data = await response.json();
      console.log(`Response from ${endpoint}:`, { status: response.status, data });
    } catch (jsonError) {
      console.error('Error parsing JSON response:', jsonError);
      throw new Error('Invalid response from server');
    }

    if (!response.ok) {
      // If token is invalid or expired, clear it
      if (response.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        
        // Only redirect if we're not already on the login page
        if (!window.location.pathname.includes('/login')) {
          const redirectUrl = `/login?from=${encodeURIComponent(window.location.pathname)}`;
          window.location.href = redirectUrl;
        }
      }
      
      const errorMessage = data?.message || data?.error || `Request failed with status ${response.status}`;
      throw new Error(errorMessage);
    }

    // Return the data property if it exists, otherwise return the whole response
    return data?.data !== undefined ? data.data : data;
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
};

// Auth API
export const authAPI = {
  login: async (email, password) => {
    try {
      // First, make the login request to get the token
      const loginResponse = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email, password }),
      });

      if (!loginResponse.ok) {
        const errorData = await loginResponse.json().catch(() => ({}));
        throw new Error(errorData.error || errorData.message || 'Login failed');
      }

      const { token } = await loginResponse.json();
      
      if (!token) {
        throw new Error('No token received from server');
      }
      
      // Store the token
      localStorage.setItem('token', token);
      
      // Now fetch the user's profile
      const userResponse = await fetch(`${API_BASE_URL}/me`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      });
      
      if (!userResponse.ok) {
        throw new Error('Failed to fetch user profile');
      }
      
      const user = await userResponse.json();
      
      // Store user data
      localStorage.setItem('user', JSON.stringify(user));
      
      return { token, user };
    } catch (error) {
      console.error('Login failed:', error);
      // Clean up on error
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      throw error;
    }
  },

  register: async (email, password) => {
    const response = await apiRequest('/auth/register', {
      method: 'POST',
      body: { email, password },
    });
    // The backend returns the token directly as a string
    const token = typeof response === 'string' ? response : response.token;
    return {
      token,
      user: { email }
    };
  },

  getCurrentUser: async () => {
    const token = localStorage.getItem('token');
    if (!token) {
      return null;
    }
    
    try {
      // Always fetch fresh user data from the server
      const response = await apiRequest('/me');
      
      if (!response) {
        throw new Error('No user data received');
      }
      
      // Update the cached user data
      localStorage.setItem('user', JSON.stringify(response));
      
      return response;
    } catch (error) {
      console.error('Error getting current user:', error);
      // If there's an error (like 401), clear the invalid token
      if (error.message.includes('401') || error.message.includes('token') || error.message.includes('Unauthorized')) {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
      }
      return null;
    }
  },

  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },
};

// Thoughts API
export const thoughtsAPI = {
  getThoughts: async () => {
    const response = await apiRequest('/thoughts');
    // The backend returns thoughts in the data field
    return Array.isArray(response) ? response : [];
  },

  createThought: async (content) => {
    const response = await apiRequest('/thoughts', {
      method: 'POST',
      body: { content },
    });
    return response;
  },

  deleteThought: async (id) => {
    await apiRequest(`/thoughts/${id}`, {
      method: 'DELETE',
    });
    return id; // Return the deleted thought id
  },
};
