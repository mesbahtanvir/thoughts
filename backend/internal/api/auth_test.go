package api_test

import (
	"bytes"
	"encoding/json"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
	"github.com/yourusername/backend/internal/testutils"
)

func TestRegister(t *testing.T) {
	db := testutils.SetupTestDB(t)
	app := testutils.SetupTestApp(t, db)

	type testCase struct {
		name           string
		payload        map[string]string
		expectedStatus int
		expectedError  string
	}

	tests := []testCase{
		{
			name: "successful registration",
			payload: map[string]string{
				"email":    "test@example.com",
				"password": "password123",
			},
			expectedStatus: fiber.StatusCreated,
		},
		{
			name:           "missing email",
			payload:        map[string]string{"password": "password123"},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Email is required",
		},
		{
			name:           "invalid email format",
			payload:        map[string]string{"email": "invalid-email", "password": "password123"},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Invalid email format",
		},
		{
			name:           "short password",
			payload:        map[string]string{"email": "test@example.com", "password": "short"},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Password must be at least 6 characters",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payload, _ := json.Marshal(tt.payload)
			req := httptest.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(payload))
			req.Header.Set("Content-Type", "application/json")

			resp, err := app.Test(req)
			if err != nil {
				t.Fatal(err)
			}

			assert.Equal(t, tt.expectedStatus, resp.StatusCode)

			if tt.expectedError != "" {
				var result map[string]string
				json.NewDecoder(resp.Body).Decode(&result)
				assert.Contains(t, result["error"], tt.expectedError)
			}
		})
	}
}

func TestLogin(t *testing.T) {
	db := testutils.SetupTestDB(t)
	app := testutils.SetupTestApp(t, db)

	// First register a test user
	registerPayload := map[string]string{
		"email":    "test@example.com",
		"password": "password123",
	}
	payload, _ := json.Marshal(registerPayload)
	req := httptest.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(payload))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req)
	if resp.StatusCode != fiber.StatusCreated {
		t.Fatalf("Failed to register test user: %d", resp.StatusCode)
	}

	tests := []struct {
		name           string
		payload        map[string]string
		expectedStatus int
		expectToken    bool
		expectedError  string
	}{
		{
			name: "successful login",
			payload: map[string]string{
				"email":    "test@example.com",
				"password": "password123",
			},
			expectedStatus: fiber.StatusOK,
			expectToken:    true,
		},
		{
			name: "invalid credentials - wrong password",
			payload: map[string]string{
				"email":    "test@example.com",
				"password": "wrongpassword",
			},
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Invalid credentials",
		},
		{
			name: "non-existent user",
			payload: map[string]string{
				"email":    "nonexistent@example.com",
				"password": "password123",
			},
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Invalid credentials",
		},
		{
			name:           "missing email",
			payload:        map[string]string{"password": "password123"},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Email is required",
		},
		{
			name:           "missing password",
			payload:        map[string]string{"email": "test@example.com"},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Password is required",
		},
		{
			name: "invalid email format",
			payload: map[string]string{
				"email":    "invalid-email",
				"password": "password123",
			},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Invalid email format",
		},
		{
			name: "short password",
			payload: map[string]string{
				"email":    "test@example.com",
				"password": "short",
			},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Password must be at least 6 characters",
		},
		{
			name:           "empty request body",
			payload:        map[string]string{},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Password is required",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payload, _ := json.Marshal(tt.payload)
			req := httptest.NewRequest("POST", "/api/auth/login", bytes.NewBuffer(payload))
			req.Header.Set("Content-Type", "application/json")

			resp, err := app.Test(req)
			if err != nil {
				t.Fatal(err)
			}

			assert.Equal(t, tt.expectedStatus, resp.StatusCode)

			var result map[string]string
			json.NewDecoder(resp.Body).Decode(&result)

			if tt.expectToken {
				assert.NotEmpty(t, result["token"])
			}

			if tt.expectedError != "" {
				assert.Contains(t, result["error"], tt.expectedError)
			}
		})
	}
}

func TestGetCurrentUser(t *testing.T) {
	db := testutils.SetupTestDB(t)
	app := testutils.SetupTestApp(t, db)

	// First register and login to get a token
	registerPayload := map[string]string{
		"email":    "test@example.com",
		"password": "password123",
	}
	registerPayloadBytes, _ := json.Marshal(registerPayload)
	req := httptest.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(registerPayloadBytes))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req)
	if resp.StatusCode != fiber.StatusCreated {
		t.Fatalf("Failed to register test user: %d", resp.StatusCode)
	}

	// Login to get token
	loginPayload := map[string]string{
		"email":    "test@example.com",
		"password": "password123",
	}
	loginPayloadBytes, _ := json.Marshal(loginPayload)
	req = httptest.NewRequest("POST", "/api/auth/login", bytes.NewBuffer(loginPayloadBytes))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req)
	if err != nil {
		t.Fatal(err)
	}

	// Extract token from response
	var loginResponse map[string]string
	err = json.NewDecoder(resp.Body).Decode(&loginResponse)
	if err != nil {
		t.Fatal(err)
	}
	token := loginResponse["token"]
	if token == "" {
		t.Fatal("No token received from login")
	}

	tests := []struct {
		name           string
		token          string
		setup          func()
		expectedStatus int
		expectedEmail  string
		expectedError  string
	}{
		{
			name:           "successful get current user",
			token:          token,
			expectedStatus: fiber.StatusOK,
			expectedEmail:  "test@example.com",
		},
		{
			name:           "missing token",
			token:          "",
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "invalid token",
			token:          "invalid.token.here",
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Invalid or expired token",
		},
		{
			name: "user not found",
			setup: func() {
				// Delete the user to simulate a user that doesn't exist
				db.Exec("DELETE FROM users WHERE email = ?", "test@example.com")
			},
			token:          token,
			expectedStatus: fiber.StatusNotFound,
			expectedError:  "User not found",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Run setup if provided
			if tt.setup != nil {
				tt.setup()
			}

			req := httptest.NewRequest("GET", "/api/me", nil)
			req.Header.Set("Content-Type", "application/json")
			if tt.token != "" {
				req.Header.Set("Authorization", "Bearer "+tt.token)
			}

			resp, err := app.Test(req)
			if err != nil {
				t.Fatal(err)
			}

			assert.Equal(t, tt.expectedStatus, resp.StatusCode)

			var result map[string]interface{}
			err = json.NewDecoder(resp.Body).Decode(&result)
			if err != nil {
				t.Fatal(err)
			}

			if tt.expectedError != "" {
				assert.Contains(t, result["error"], tt.expectedError)
			}

			if tt.expectedEmail != "" {
				assert.Equal(t, tt.expectedEmail, result["email"])
				assert.NotEmpty(t, result["id"])
				assert.NotEmpty(t, result["created_at"])
				assert.NotNil(t, result["email_verified"])
			}
		})
	}
}
