package api

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/yourusername/thoughts-backend/internal/auth"
	"github.com/yourusername/thoughts-backend/internal/models"
	"gorm.io/gorm"
)

type CreateThoughtRequest struct {
	Content string `json:"content" validate:"required,min=1,max=500"`
}

// CreateThought handles creating a new thought
func CreateThought(c *fiber.Ctx, db *gorm.DB) error {
	user, err := auth.GetUserFromContext(c, db)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	var req CreateThoughtRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request",
		})
	}

	// Check if content is provided
	if req.Content == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Content is required",
		})
	}

	// Trim whitespace and validate content
	trimmedContent := strings.TrimSpace(req.Content)
	if len(trimmedContent) == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Content cannot be empty",
		})
	}

	// Validate content length
	if len(trimmedContent) > 1000 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Content too long",
		})
	}

	// Update content with trimmed version
	req.Content = trimmedContent

	thought := models.Thought{
		Content: req.Content,
		UserID:  user.ID,
	}

	if err := db.Create(&thought).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Could not create thought",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(thought)
}

// GetThoughts gets all thoughts for the authenticated user
func GetThoughts(c *fiber.Ctx, db *gorm.DB) error {
	user, err := auth.GetUserFromContext(c, db)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	var thoughts []models.Thought
	if err := db.Where("user_id = ?", user.ID).Order("created_at DESC").Find(&thoughts).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Could not fetch thoughts",
		})
	}

	return c.JSON(thoughts)
}
