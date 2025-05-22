package api_test

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/stretchr/testify/assert"

	"github.com/yourusername/backend/internal/models"
	"github.com/yourusername/backend/internal/testutils"
)

func TestThoughtsController(t *testing.T) {
	db := testutils.SetupTestDB(t)
	app := testutils.SetupTestApp(t, db)

	// Register and login to get a token
	token, _ := registerAndLoginTestUser(t, app, "test@example.com", "password123")

	t.Run("CreateThought", func(t *testing.T) {
		// Clear any existing thoughts
		db.Exec("DELETE FROM thoughts")
		tests := []struct {
			name           string
			token          string
			payload        map[string]string
			expectedStatus int
			expectedError  string
		}{
			{
				name: "successful thought creation",
				token: token,
				payload: map[string]string{
					"content": "This is a test thought",
				},
				expectedStatus: fiber.StatusCreated,
			},
			{
				name:    "missing token",
				token:   "",
				payload: map[string]string{"content": "Test thought"},
				expectedStatus: fiber.StatusUnauthorized,
				expectedError:  "Unauthorized",
			},
			{
				name:    "empty content",
				token:   token,
				payload: map[string]string{"content": ""},
				expectedStatus: fiber.StatusBadRequest,
				expectedError:  "Content is required",
			},
			{
				name:  "content too long",
				token: token,
				payload: map[string]string{
					"content": "This is a very long thought that exceeds the maximum allowed length of 1000 characters. " +
						"Lorem ipsum dolor sit amet, consectetur adipiscing elit. " +
						strings.Repeat("This is a very long thought that exceeds the maximum allowed length. ", 20),
				},
				expectedStatus: fiber.StatusBadRequest,
				expectedError:  "Content too long",
			},
		}

		for _, tt := range tests {
			t.Run(tt.name, func(t *testing.T) {
				// Clear thoughts before each test case
				db.Exec("DELETE FROM thoughts")

				payload, _ := json.Marshal(tt.payload)
				req := httptest.NewRequest("POST", "/api/thoughts", bytes.NewBuffer(payload))
				req.Header.Set("Content-Type", "application/json")
				if tt.token != "" {
					req.Header.Set("Authorization", "Bearer "+tt.token)
				}

				resp, err := app.Test(req)
				assert.NoError(t, err)
				defer resp.Body.Close()

				assert.Equal(t, tt.expectedStatus, resp.StatusCode, "Unexpected status code")

				if tt.expectedError != "" {
					var result map[string]string
					err = json.NewDecoder(resp.Body).Decode(&result)
					assert.NoError(t, err)
					assert.Contains(t, result["error"], tt.expectedError, "Unexpected error message")
				}

				if resp.StatusCode == http.StatusCreated {
					var responseThought models.Thought
					err := json.NewDecoder(resp.Body).Decode(&responseThought)
					assert.NoError(t, err)
					assert.Equal(t, tt.payload["content"], responseThought.Content)
					assert.NotZero(t, responseThought.ID)
					assert.NotZero(t, responseThought.CreatedAt)

					// Verify the thought was saved to the database
					var dbThought models.Thought
					err = db.First(&dbThought, responseThought.ID).Error
					assert.NoError(t, err)
					assert.Equal(t, tt.payload["content"], dbThought.Content)
				}
			})
		}
	})

	t.Run("GetThoughts", func(t *testing.T) {
		// Create a fresh token and user for this test
		token2, userID2 := registerAndLoginTestUser(t, app, "test2@example.com", "password123")

		// Print debug info
		t.Logf("Created user with ID: %d", userID2)

		// Create test thoughts for this user directly in the database
		thoughts := []models.Thought{
			{UserID: userID2, Content: "First thought"},
			{UserID: userID2, Content: "Second thought"},
		}
		for i := range thoughts {
			err := db.Create(&thoughts[i]).Error
			assert.NoError(t, err, "Failed to create test thought")
			t.Logf("Created thought with ID: %d, UserID: %d, Content: %s", thoughts[i].ID, thoughts[i].UserID, thoughts[i].Content)
		}

		// Verify the thoughts were created
		var count int64
		err := db.Model(&models.Thought{}).Count(&count).Error
		assert.NoError(t, err)
		t.Logf("Total thoughts in database: %d", count)

		// Count thoughts for this user
		err = db.Model(&models.Thought{}).Where("user_id = ?", userID2).Count(&count).Error
		assert.NoError(t, err)
		t.Logf("Thoughts for user %d: %d", userID2, count)

		// List all thoughts for debugging
		var allThoughts []models.Thought
		err = db.Find(&allThoughts).Error
		assert.NoError(t, err)
		for i, thought := range allThoughts {
			t.Logf("Thought %d: ID=%d, UserID=%d, Content=%s", i, thought.ID, thought.UserID, thought.Content)
		}

		assert.Equal(t, int64(2), count, "Expected 2 test thoughts in the database")

		t.Run("successful retrieval", func(t *testing.T) {
			t.Log("Sending GET /api/thoughts request...")
			req := httptest.NewRequest("GET", "/api/thoughts", nil)
			req.Header.Set("Authorization", "Bearer "+token2)

			resp, err := app.Test(req)
			assert.NoError(t, err)
			defer resp.Body.Close()

			t.Logf("Response status: %d", resp.StatusCode)
			assert.Equal(t, http.StatusOK, resp.StatusCode, "Unexpected status code")

			// Read the response body
			body, err := io.ReadAll(resp.Body)
			assert.NoError(t, err, "Failed to read response body")
			t.Logf("Response body: %s", string(body))

			// Parse the response
			var result []models.Thought
			err = json.Unmarshal(body, &result)
			assert.NoError(t, err, "Failed to decode response body")

			t.Logf("Decoded %d thoughts from response", len(result))

			// Verify the response
			assert.Len(t, result, 2, "Expected 2 thoughts in the response")

			// Convert to a map for easier lookup
			contentMap := make(map[string]bool)
			for _, thought := range result {
				contentMap[thought.Content] = true
			}

			// Check that both expected thoughts are present
			assert.True(t, contentMap["First thought"], "Expected 'First thought' in response")
			assert.True(t, contentMap["Second thought"], "Expected 'Second thought' in response")

			// Verify the structure of the thoughts
			for _, thought := range result {
				assert.NotZero(t, thought.ID, "Thought ID should not be zero")
				assert.Equal(t, userID2, thought.UserID, "User ID mismatch")
				assert.False(t, thought.CreatedAt.IsZero(), "CreatedAt should be set")
				assert.False(t, thought.UpdatedAt.IsZero(), "UpdatedAt should be set")
			}
		})

		t.Run("unauthorized access", func(t *testing.T) {
			req := httptest.NewRequest("GET", "/api/thoughts", nil)
			resp, err := app.Test(req)
			assert.NoError(t, err)
			assert.Equal(t, http.StatusUnauthorized, resp.StatusCode)
		})
	})
}

// registerAndLoginTestUser is a helper function to register and login a test user
func registerAndLoginTestUser(t *testing.T, app *fiber.App, email, password string) (string, uint) {
	t.Helper()

	// Register
	registerPayload, _ := json.Marshal(map[string]string{
		"email":    email,
		"password": password,
	})


	req := httptest.NewRequest("POST", "/api/auth/register", bytes.NewBuffer(registerPayload))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Failed to register test user: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		body, _ := io.ReadAll(resp.Body)
		t.Fatalf("Failed to register test user. Status: %d, Body: %s", resp.StatusCode, string(body))
	}

	// Login
	loginPayload, _ := json.Marshal(map[string]string{
		"email":    email,
		"password": password,
	})


	req = httptest.NewRequest("POST", "/api/auth/login", bytes.NewBuffer(loginPayload))
	req.Header.Set("Content-Type", "application/json")
	resp, err = app.Test(req)
	if err != nil {
		t.Fatalf("Failed to login test user: %v", err)
	}

	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("Failed to read login response body: %v", err)
	}

	// Log the response for debugging
	t.Logf("Login response: %s", string(body))

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("Login failed. Status: %d, Body: %s", resp.StatusCode, string(body))
	}

	// Parse the response to get the token
	var result struct {
		Token string `json:"token"`
	}

	if err := json.Unmarshal(body, &result); err != nil {
		t.Fatalf("Failed to decode login response: %v", err)
	}

	if result.Token == "" {
		t.Fatal("Empty token in login response")
	}

	// Extract user ID from the token
	token, _, err := new(jwt.Parser).ParseUnverified(result.Token, jwt.MapClaims{})
	if err != nil {
		t.Fatalf("Failed to parse JWT token: %v", err)
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		t.Fatal("Failed to parse JWT claims")
	}

	userID, ok := claims["user_id"].(float64)
	if !ok {
		t.Fatal("user_id not found in JWT claims")
	}

	if userID == 0 {
		t.Fatal("User ID is 0 in JWT token")
	}

	t.Logf("Extracted user ID %d from JWT token", uint(userID))

	return result.Token, uint(userID)
}
