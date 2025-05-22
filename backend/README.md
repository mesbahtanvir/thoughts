# Thoughts Backend

A Go backend for the Thoughts application that handles user authentication and thought management.

## Prerequisites

- Go 1.21 or later
- SQLite (for development)

## Setup

1. Clone the repository
2. Copy `.env.example` to `.env` and update the values:
   ```bash
   cp .env.example .env
   ```
3. Install dependencies:
   ```bash
   go mod tidy
   ```

## Running the Application

1. Start the server:
   ```bash
   go run cmd/backend/main.go
   ```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login with email and password

### Thoughts (Protected)

- `GET /api/thoughts` - Get all thoughts for the authenticated user
- `POST /api/thoughts` - Create a new thought

## Environment Variables

### Required
- `JWT_SECRET` - Secret key used for signing and verifying JWT tokens
  - **Security Note**: Must be a strong, random string in production
  - **Example**: `openssl rand -base64 32`
  - **Important**: Never commit this value to version control

### Optional
- `PORT` - Port to run the server on (default: 8080)
- `ENVIRONMENT` - Application environment (e.g., development, production)
- `DATABASE_URL` - Database connection string (if not using SQLite)

## Security Considerations

### JWT_SECRET
- The `JWT_SECRET` is used to sign and verify all authentication tokens
- In production, use a strong, randomly generated string
- Rotate the secret periodically and invalidate existing tokens when rotated
- Never log or expose the secret in client-side code

### Token Security
- Tokens are set as HTTP-only cookies for web clients
- Tokens have a reasonable expiration time
- Always use HTTPS in production to prevent token interception
