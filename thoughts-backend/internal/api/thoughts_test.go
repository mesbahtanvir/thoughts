package api_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/stretchr/testify/assert"
	"github.com/yourusername/thoughts-backend/internal/models"
	"github.com/yourusername/thoughts-backend/internal/testutils"
	"gorm.io/gorm"
)

func TestCreateThought(t *testing.T) {
	db := testutils.SetupTestDB(t)
	app := testutils.SetupTestApp(t, db)

	// First register and login to get a token
	token, _ := registerAndLogin(t, app, "test@example.com", "password123")

	tests := []struct {
		name           string
		token          string
		payload        map[string]string
		setup          func() (*http.Request, *httptest.ResponseRecorder)
		expectedStatus int
		expectedError  string
	}{
		{
			name:  "successful thought creation",
			token: token,
			payload: map[string]string{
				"content": "This is a test thought",
			},
			expectedStatus: fiber.StatusCreated,
		},
		{
			name:           "missing token",
			token:          "",
			payload:        map[string]string{"content": "Test thought"},
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:  "max length content",
			token: token,
			payload: map[string]string{
				"content": strings.Repeat("a", 1000), // Assuming 1000 is max length
			},
			expectedStatus: fiber.StatusCreated,
		},
		{
			name:  "content with special characters",
			token: token,
			payload: map[string]string{
				"content": "Special chars: !@#$%^&*()_+{}[]|\\:;\"'<>,.?/~`",
			},
			expectedStatus: fiber.StatusCreated,
		},
		{
			name:  "content with emojis",
			token: token,
			payload: map[string]string{
				"content": "Thought with emojis 😊🚀🌟",
			},
			expectedStatus: fiber.StatusCreated,
		},
		{
			name:  "content with newlines",
			token: token,
			payload: map[string]string{
				"content": "First line\nSecond line\nThird line",
			},
			expectedStatus: fiber.StatusCreated,
		},
		{
			name:  "content with HTML tags",
			token: token,
			payload: map[string]string{
				"content": "<script>alert('xss')</script>",
			},
			expectedStatus: fiber.StatusCreated,
		},
		{
			name:  "empty content",
			token: token,
			payload: map[string]string{
				"content": "",
			},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Content is required",
		},
		{
			name:  "whitespace only content",
			token: token,
			payload: map[string]string{
				"content": "   \n  \t  ",
			},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Content cannot be empty",
		},
		{
			name:           "missing content field",
			token:          token,
			payload:        map[string]string{},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Content is required",
		},
		{
			name:  "content too long",
			token: token,
			payload: map[string]string{
				"content": strings.Repeat("a", 1001), // Assuming 1000 is max length
			},
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Content too long",
		},
		{
			name:  "invalid token",
			token: "invalid.token.here",
			payload: map[string]string{
				"content": "Should fail with invalid token",
			},
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Invalid or expired token",
		},
		{
			name:  "expired token",
			token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MTYyMzkwMjJ9.8nRhWEUHF4BQQEcgZk0yW4hUJzF7irqBst7w4DZgQ7Y",
			payload: map[string]string{
				"content": "Should fail with expired token",
			},
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Invalid or expired token",
		},
		{
			name: "malformed json",
			setup: func() (*http.Request, *httptest.ResponseRecorder) {
				req := httptest.NewRequest("POST", "/api/thoughts", strings.NewReader(`{"content": "test"`)) // Missing closing brace
				req.Header.Set("Content-Type", "application/json")
				req.Header.Set("Authorization", "Bearer "+token)
				return req, httptest.NewRecorder()
			},
			token:          token,
			expectedStatus: fiber.StatusBadRequest,
			expectedError:  "Invalid request",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var req *http.Request
			var resp *http.Response
			var err error

			if tt.setup != nil {
				// Use custom setup for special cases like malformed JSON
				req, _ = tt.setup()
				resp, err = app.Test(req)
			} else {
				// Standard test case
				payload, _ := json.Marshal(tt.payload)
				req = httptest.NewRequest("POST", "/api/thoughts", bytes.NewBuffer(payload))
				req.Header.Set("Content-Type", "application/json")
				if tt.token != "" {
					req.Header.Set("Authorization", "Bearer "+tt.token)
				}
				resp, err = app.Test(req)
			}

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

func TestGetThoughts(t *testing.T) {
	db := testutils.SetupTestDB(t)
	app := testutils.SetupTestApp(t, db)

	// Register, login and create a thought
	token, userID := registerAndLogin(t, app, "test@example.com", "password123")
	createTestThought(t, db, userID, "First thought")
	createTestThought(t, db, userID, "Second thought")

	tests := []struct {
		name           string
		token          string
		expectedStatus int
		expectedCount  int
		expectedError  string
	}{
		{
			name:           "get all thoughts",
			token:          token,
			expectedStatus: fiber.StatusOK,
			expectedCount:  2,
		},
		// We're only creating 2 thoughts in setup, so we'll expect 2
		{
			name:           "get thoughts count",
			token:          token,
			expectedStatus: fiber.StatusOK,
			expectedCount:  2,
		},
		{
			name:           "unauthorized access",
			token:          "invalid-token",
			expectedStatus: fiber.StatusUnauthorized,
			expectedError:  "Invalid or expired token",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", "/api/thoughts", nil)
			req.Header.Set("Authorization", "Bearer "+tt.token)

			resp, err := app.Test(req)
			if err != nil {
				t.Fatal(err)
			}

			assert.Equal(t, tt.expectedStatus, resp.StatusCode)

			if tt.expectedCount > 0 {
				var result []map[string]interface{}
				json.NewDecoder(resp.Body).Decode(&result)
				assert.Len(t, result, tt.expectedCount)
			}

			if tt.expectedError != "" {
				var result map[string]string
				json.NewDecoder(resp.Body).Decode(&result)
				assert.Contains(t, result["error"], tt.expectedError)
			}
		})
	}
}

// Helper function to register and login a test user
func registerAndLogin(t *testing.T, app *fiber.App, email, password string) (string, uint) {
	// Register
	registerPayload, _ := json.Marshal(map[string]string{
		"email":    email,
		"password": password,
	})
	req := httptest.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(registerPayload))
	req.Header.Set("Content-Type", "application/json")
	resp, _ := app.Test(req)

	// Login
	loginPayload, _ := json.Marshal(map[string]string{
		"email":    email,
		"password": password,
	})
	req = httptest.NewRequest("POST", "/api/auth/login", bytes.NewBuffer(loginPayload))
	req.Header.Set("Content-Type", "application/json")
	resp, _ = app.Test(req)

	var result map[string]string
	json.NewDecoder(resp.Body).Decode(&result)

	token := result["token"]

	// Get user ID from token
	claims := jwt.MapClaims{}
	_, _ = jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(os.Getenv("JWT_SECRET")), nil
	})

	userID := uint(claims["user_id"].(float64))

	return token, userID
}

// Helper function to create test thoughts
func createTestThought(t *testing.T, db *gorm.DB, userID uint, content string) {
	thought := models.Thought{
		Content: content,
		UserID:  userID,
	}
	if err := db.Create(&thought).Error; err != nil {
		t.Fatalf("Failed to create test thought: %v", err)
	}
}
