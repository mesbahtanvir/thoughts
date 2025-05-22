package database

import (
	"os"
	"path/filepath"

	"github.com/yourusername/backend/internal/models"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// DB is the database connection
var DB *gorm.DB

// Connect initializes a database connection
func Connect() (*gorm.DB, error) {
	// Get database path from environment variable or use default
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "thoughts.db"
	} else {
		// Ensure the directory exists
		dir := filepath.Dir(dbPath)
		if err := os.MkdirAll(dir, 0755); err != nil {
			return nil, err
		}
	}

	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	DB = db
	return db, nil
}

// Migrate runs database migrations
func Migrate(db *gorm.DB) error {
	return db.AutoMigrate(
		&models.User{},
		&models.Thought{},
	)
}
