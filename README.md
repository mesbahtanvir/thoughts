
# Thoughts Application

A full-stack web application for sharing and managing thoughts, built with Go (backend) and React (frontend), deployed on AWS infrastructure.

## 🌟 Features

- **User Authentication**: Secure JWT-based authentication system
- **Thought Management**: Create, view, and manage your thoughts
- **Responsive Design**: Works on desktop and mobile devices
- **Scalable Architecture**: Built with cloud-native principles
- **CI/CD**: Automated testing and deployment pipeline

## 🚀 Quick Start

### Prerequisites

- [Go](https://golang.org/dl/) 1.21+ (for backend)
- [Node.js](https://nodejs.org/) 16+ and npm (for frontend)
- [Terraform](https://www.terraform.io/downloads.html) 1.0.0+
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Docker](https://www.docker.com/) (for containerized deployment)

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

### Environment Variables

#### Backend
- `PORT` - Port to run the server on (default: 8080)
- `JWT_SECRET` - Secret key for JWT token generation (required for production)
- `DB_PATH` - Path to SQLite database file (default: thoughts.db in project root)

#### Frontend
- `REACT_APP_API_URL` - URL of the backend API (default: http://localhost:8080/api)

4. Access the application at `http://localhost:3000`

## 🏗️ Deployment

### Infrastructure as Code

The application is deployed on AWS using Terraform. The infrastructure includes:

- **Frontend**: S3 + CloudFront (CDN)
- **Backend**: EC2 instance with auto-scaling
- **Database**: RDS (PostgreSQL)
- **Networking**: VPC, subnets, security groups
- **Security**: IAM roles, KMS encryption, WAF

### Deployment Steps

1. **Configure AWS credentials**
   ```bash
   aws configure
   ```

2. **Initialize Terraform**
   ```bash
   cd deployment/terraform
   terraform init
   ```

3. **Review the plan**
   ```bash
   terraform plan
   ```

4. **Deploy the infrastructure**
   ```bash
   terraform apply
   ```

5. **Access the application**
   - Frontend URL: `https://d27gaeqjiw3uw0.cloudfront.net`
   - Backend API: `http://ec2-xxx-xxx-xxx-xxx.compute-1.amazonaws.com/api`

## 🛠️ Project Structure

```
.
├── backend/               # Go backend application
│   ├── cmd/               # Application entry points
│   ├── internal/          # Core application logic
│   ├── pkg/               # Reusable packages
│   └── Dockerfile         # Container configuration
│
├── frontend/             # React frontend application
│   ├── public/            # Static files
│   ├── src/               # React components and logic
│   └── Dockerfile         # Container configuration
│
├── deployment/           # Infrastructure as Code
│   └── terraform/         # Terraform configurations
│       ├── modules/       # Reusable modules
│       ├── main.tf        # Main configuration
│       └── variables.tf   # Variable definitions
│
└── .github/workflows/    # CI/CD pipelines
```

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
