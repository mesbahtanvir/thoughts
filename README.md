
# Thoughts Application

A full-stack web application for sharing and managing thoughts, built with Go (backend) and React (frontend), deployed on AWS infrastructure.

## 🏗️ Project Structure

```
.
├── backend/                  # Go backend application
│   ├── cmd/                  # Application entry points
│   │   └── backend/          # Main application entry point
│   ├── config/              # Configuration files
│   └── internal/            # Core application code
│       ├── api/             # HTTP handlers and routes
│       ├── auth/            # Authentication logic
│       ├── client/          # API client code
│       ├── database/        # Database models and migrations
│       └── models/          # Data models
│
├── deployment/             # Infrastructure as Code
│   └── terraform/           # Terraform configurations
│       └── modules/         # Reusable infrastructure modules
│           ├── backend/     # Backend infrastructure
│           └── frontend/    # Frontend infrastructure
│
├── frontend/               # React frontend application
│   ├── public/             # Static files
│   └── src/                # Source code
│       ├── components/     # React components
│       └── services/      # API services and utilities
│
├── .github/workflows/     # GitHub Actions workflows
├── .tfsec.yml             # Security scanning configuration
└── LICENSE                # MIT License
```

## 🌟 Features

- **User Authentication**: Secure JWT-based authentication system
- **Thought Management**: Create, view, and manage thoughts
- **Responsive Design**: Works on desktop and mobile devices
- **Cloud-Native**: Deployed on AWS with infrastructure as code
- **CI/CD**: Automated testing and deployment pipeline

## 🛠️ Development Setup

### Prerequisites

- [Go](https://golang.org/dl/) 1.21+ (for backend)
- [Node.js](https://nodejs.org/) 16+ and npm (for frontend)
- [Terraform](https://www.terraform.io/downloads.html) 1.0.0+ (for infrastructure)
- [AWS CLI](https://aws.amazon.com/cli/) (for deployment)
- [Docker](https://www.docker.com/) (optional, for containerized development)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/thoughts.git
   cd thoughts
   ```

2. **Set up the backend**
   ```bash
   cd backend
   go mod download
   # The backend uses SQLite by default (creates thoughts.db in the project root)
   # To customize the database location, set the DB_PATH environment variable
   # The backend runs on port 8080 by default
   # To change the port, set the PORT environment variable
   go run cmd/backend/main.go
   ```

3. **Set up the frontend**
   ```bash
   cd ../frontend
   npm install
   # The frontend will use http://localhost:8080/api by default
   # To override, set REACT_APP_API_URL environment variable:
   # On Unix/Linux: export REACT_APP_API_URL=http://your-api-url
   # On Windows: set REACT_APP_API_URL=http://your-api-url
   npm start
   ```

4. Access the application at `http://localhost:3000`

### Environment Variables

#### Backend
- `PORT` - Port to run the server on (default: 8080)
- `JWT_SECRET` - Secret key for JWT token generation (required for production)
- `DB_PATH` - Path to SQLite database file (default: thoughts.db in project root)

#### Frontend
- `REACT_APP_API_URL` - URL of the backend API (default: http://localhost:8080/api)

## ☁️ Production Deployment

### Infrastructure Overview

The application is deployed on AWS with the following components:

- **Frontend**
  - S3 bucket for static assets
  - CloudFront CDN for global distribution
  - HTTPS with custom domain support
  - Cache invalidation on deployment

- **Backend**
  - EC2 instance (t3.micro)
  - Auto Scaling Group for high availability
  - Application Load Balancer
  - Security groups with least-privilege access

- **Data**
  - RDS PostgreSQL database
  - Automated backups
  - Encryption at rest and in transit

- **Security**
  - IAM roles with least privilege
  - KMS encryption for sensitive data
  - Web Application Firewall (WAF)
  - Security group rules

### Deployment Process

1. **Prerequisites**
   - AWS account with appropriate permissions
   - Domain name (optional)
   - SSL certificate in AWS Certificate Manager

2. **Deploy Infrastructure**
   ```bash
   cd deployment/terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. **Deploy Frontend**
   ```bash
   cd ../../frontend
   npm run build
   # The build will be automatically uploaded to S3 by Terraform
   ```

4. **Access the Application**
   - Frontend URL: `https://d27gaeqjiw3uw0.cloudfront.net`
   - Backend API: `http://ec2-xxx-xxx-xxx-xxx.compute-1.amazonaws.com/api`

### CI/CD Pipeline

The project includes GitHub Actions workflows for:
- Automated testing on pull requests
- Frontend deployment on push to main
- Security scanning with tfsec and Checkov

## 🔒 Security

### Authentication & Authorization
- All API endpoints are protected with JWT authentication
- JWT tokens are signed using the `JWT_SECRET` environment variable
  - **Important**: Always use a strong, random string for production
  - Never commit the actual secret to version control
  - Rotate the secret periodically in production environments

### Environment Variables
- Sensitive configuration is managed through environment variables
- Required variables:
  - `JWT_SECRET`: Used for signing and verifying JWT tokens
  - `PORT`: Port the backend server listens on (default: 8080)
  - `DATABASE_URL`: Database connection string (for non-SQLite environments)

### Security Scanning
- Regular security scanning with tfsec and Checkov
- Dependabot for dependency updates
- GitHub Actions workflows for automated security checks

## 🔧 Maintenance

### Database Migrations

```bash
cd backend
go run cmd/backend/main.go migrate
```

### Monitoring

- CloudWatch Logs for application logs
- CloudWatch Metrics for performance monitoring
- S3 access logs for audit trails
- CloudFront access logs

### Scaling

- **Horizontal Scaling**: Adjust the `desired_capacity` in the Auto Scaling Group
- **Vertical Scaling**: Update the `instance_type` in Terraform config
- **Database**: Consider RDS read replicas for read-heavy workloads



## 🔒 Security

- All data is encrypted at rest and in transit
- Regular security updates and patches
- IAM roles with least privilege
- Security group rules for network access control
- Automated vulnerability scanning in CI/CD

## 📈 Monitoring and Logging

- CloudWatch Logs for application logs
- CloudWatch Metrics for performance monitoring
- S3 access logs for auditing
- CloudFront access logs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Go](https://golang.org/) - The programming language used for the backend
- [React](https://reactjs.org/) - Frontend library
- [Terraform](https://www.terraform.io/) - Infrastructure as Code tool
- [AWS](https://aws.amazon.com/) - Cloud infrastructure

## 📧 Contact

For any questions or feedback, please open an issue in the repository.
