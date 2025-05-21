package auth

import (
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/yourusername/backend/internal/models"
	"gorm.io/gorm"
	"os"
	"strings"
)

// Protected protects routes
func Protected() fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Unauthorized",
			})
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte(os.Getenv("JWT_SECRET")), nil
		})

		if err != nil || !token.Valid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Invalid or expired token",
			})
		}

		claims := token.Claims.(jwt.MapClaims)
		userID := uint(claims["user_id"].(float64))

		// Set user ID in locals for use in route handlers
		c.Locals("userID", userID)
		return c.Next()
	}
}

// GetUserFromContext gets the user from the context
func GetUserFromContext(c *fiber.Ctx, db *gorm.DB) (*models.User, error) {
	userID, ok := c.Locals("userID").(uint)
	if !ok {
		return nil, fiber.ErrUnauthorized
	}

	var user models.User
	if err := db.First(&user, userID).Error; err != nil {
		return nil, err
	}

	return &user, nil
}
