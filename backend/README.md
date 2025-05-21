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

- `JWT_SECRET` - Secret key for JWT token generation
- `PORT` - Port to run the server on (default: 8080)
