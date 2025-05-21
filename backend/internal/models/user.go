package models

import (
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Email               string    `gorm:"unique;not null" json:"email"`
	Password            string    `gorm:"not null" json:"-"`
	EmailVerified       bool      `gorm:"default:false" json:"email_verified"`
	VerificationToken   string    `gorm:"size:255" json:"-"`
	Thoughts           []Thought  `gorm:"foreignKey:UserID" json:"thoughts"`
}

// BeforeCreate hashes the password before saving to database
func (u *User) BeforeCreate(tx *gorm.DB) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.Password = string(hashedPassword)
	return nil
}

// CheckPassword verifies the password
func (u *User) CheckPassword(password string) error {
	return bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
}
