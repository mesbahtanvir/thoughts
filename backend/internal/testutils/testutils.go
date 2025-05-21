package testutils

import (
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/yourusername/backend/internal/api"
	"github.com/yourusername/backend/internal/database"
	"gorm.io/gorm"
)

// SetupTestDB initializes a test database with migrations
func SetupTestDB(t *testing.T) *gorm.DB {
	db, err := database.Connect()
	if err != nil {
		t.Fatalf("Failed to connect to test database: %v", err)
	}

	// Clear all tables
	db.Exec("DROP TABLE IF EXISTS thoughts")
	db.Exec("DROP TABLE IF EXISTS users")

	// Re-run migrations
	if err := database.Migrate(db); err != nil {
		t.Fatalf("Failed to migrate test database: %v", err)
	}

	return db
}

// SetupTestApp initializes a test Fiber app with routes
func SetupTestApp(t *testing.T, db *gorm.DB) *fiber.App {
	app := fiber.New()
	api.SetupRoutes(app, db)
	return app
}
