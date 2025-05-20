package api

import (
	"github.com/gofiber/fiber/v2"
	"github.com/yourusername/thoughts-backend/internal/auth"
	"gorm.io/gorm"
)

// SetupRoutes configures all the routes for the application
func SetupRoutes(app *fiber.App, db *gorm.DB) {
	// Health check endpoint
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.SendString("OK")
	})

	// Auth routes
	authGroup := app.Group("/api/auth")
	authGroup.Post("/login", func(c *fiber.Ctx) error {
		return Login(c, db)
	})
	authGroup.Post("/register", func(c *fiber.Ctx) error {
		return Register(c, db)
	})

	// Protected routes
	api := app.Group("/api", auth.Protected())

	// User routes
	api.Get("/me", func(c *fiber.Ctx) error {
		return GetCurrentUser(c, db)
	})

	// Thoughts routes
	thoughtsGroup := api.Group("/thoughts")
	thoughtsGroup.Get("", func(c *fiber.Ctx) error {
		return GetThoughts(c, db)
	})
	thoughtsGroup.Post("", func(c *fiber.Ctx) error {
		return CreateThought(c, db)
	})
}
