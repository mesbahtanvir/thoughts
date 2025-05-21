package client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/yourusername/backend/internal/models"
)

type Client struct {
	BaseURL    string
	HTTPClient *http.Client
	Token      string
}

func NewClient(baseURL string) *Client {
	return &Client{
		BaseURL: baseURL,
		HTTPClient: &http.Client{
			Timeout: time.Minute,
		},
	}
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginResponse struct {
	Token string `json:"token"`
}

// Login authenticates a user and stores the JWT token
func (c *Client) Login(email, password string) error {
	loginReq := LoginRequest{
		Email:    email,
		Password: password,
	}

	resp, err := c.doRequest("POST", "/api/auth/login", loginReq)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("login failed with status: %s", resp.Status)
	}

	var loginResp LoginResponse
	if err := json.NewDecoder(resp.Body).Decode(&loginResp); err != nil {
		return fmt.Errorf("failed to decode login response: %w", err)
	}

	c.Token = loginResp.Token
	return nil
}

// CreateThought creates a new thought
func (c *Client) CreateThought(content string) (*models.Thought, error) {
	thought := map[string]string{"content": content}
	
	resp, err := c.doRequest("POST", "/api/thoughts", thought)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		return nil, fmt.Errorf("failed to create thought: %s", resp.Status)
	}

	var createdThought models.Thought
	if err := json.NewDecoder(resp.Body).Decode(&createdThought); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &createdThought, nil
}

// GetThoughts retrieves all thoughts
func (c *Client) GetThoughts() ([]models.Thought, error) {
	resp, err := c.doRequest("GET", "/api/thoughts", nil)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to get thoughts: %s", resp.Status)
	}

	var thoughts []models.Thought
	if err := json.NewDecoder(resp.Body).Decode(&thoughts); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return thoughts, nil
}

// doRequest is a helper method to make HTTP requests
func (c *Client) doRequest(method, path string, body interface{}) (*http.Response, error) {
	var reqBody io.Reader = nil

	if body != nil {
		jsonData, err := json.Marshal(body)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal request body: %w", err)
		}
		reqBody = bytes.NewBuffer(jsonData)
	}

	req, err := http.NewRequest(method, c.BaseURL+path, reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	if c.Token != "" {
		req.Header.Set("Authorization", "Bearer "+c.Token)
	}

	return c.HTTPClient.Do(req)
}
