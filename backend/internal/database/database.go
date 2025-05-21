package database

import (
	"github.com/yourusername/backend/internal/models"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// DB is the database connection
var DB *gorm.DB

// Connect initializes a database connection
func Connect() (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open("thoughts.db"), &gorm.Config{})
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
