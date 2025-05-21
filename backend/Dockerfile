# Build stage
FROM golang:1.20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o backend ./cmd/backend

# Final stage
FROM alpine:latest

# Install necessary runtime dependencies
RUN apk --no-cache add ca-certificates

# Set working directory
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/backend /app/backend

# Create a non-root user
RUN adduser -D -g '' appuser && \
    chown -R appuser:appuser /app
USER appuser

# Create directories that need to be writable
RUN mkdir -p /app/data && \
    chown -R appuser:appuser /app/data

# Build arguments
ARG JWT_SECRET=default_jwt_secret_change_in_production
ARG ENVIRONMENT=production

# Environment variables
ENV PORT=8080
ENV JWT_SECRET=${JWT_SECRET}
ENV ENVIRONMENT=${ENVIRONMENT}

# Expose the port the app runs on
EXPOSE $PORT

# Set the entry point
ENTRYPOINT ["/app/backend"]
