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

# Use a small alpine image for the final stage
FROM alpine:latest

# Install necessary runtime dependencies
RUN apk --no-cache add ca-certificates

# Set working directory
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/backend /app/backend

# Copy any required configuration files
COPY --from=builder /app/.env /app/.env
COPY --from=builder /app/thoughts.db /app/thoughts.db

# Expose port
EXPOSE 8080

# Start the application
CMD ["/app/backend"]
