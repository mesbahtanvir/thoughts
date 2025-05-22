FROM golang:1.21-bullseye AS builder

# Set working directory
WORKDIR /app

# Install dependencies for CGO and SQLite
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    libsqlite3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application with CGO enabled for SQLite
RUN CGO_ENABLED=1 GOOS=linux go build -a -o backend ./cmd/backend

# Final stage - use Debian slim for smaller size but compatible with the builder
FROM debian:bullseye-slim

# Install required packages for production
RUN apt-get update && apt-get install -y \
    ca-certificates \
    tzdata \
    sqlite3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/backend .

# Create directory for SQLite database
RUN mkdir -p /app/data

# Build arguments
ARG JWT_SECRET
ARG ENVIRONMENT=production

# Set environment variables
ENV PORT=8080
ENV JWT_SECRET=${JWT_SECRET}
ENV ENVIRONMENT=${ENVIRONMENT}

# Expose the application port
EXPOSE 8080

# Command to run the executable
CMD ["./backend"]
