# Create an IAM role for the EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "${var.app_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allow EC2 to pull from ECR and GHCR
resource "aws_iam_role_policy" "ecr_pull_policy" {
  name = "${var.app_name}-${var.environment}-ecr-pull-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Create instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.app_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Create a security group for the EC2 instance
resource "aws_security_group" "ec2_sg" {
  name        = "${var.app_name}-${var.environment}-backend-sg"
  description = "Security group for backend EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access from anywhere (restrict in production!)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "${var.app_name}-${var.environment}-backend-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data = templatefile("${path.module}/user_data.sh", {
    app_name     = var.app_name
    environment  = var.environment
    github_token = var.github_token
    jwt_secret   = var.jwt_secret
  })

  tags = {
    Name = "${var.app_name}-${var.environment}-backend"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

# Create Elastic IP for the instance
resource "aws_eip" "backend_eip" {
  instance = aws_instance.backend.id
  domain   = "vpc"

  tags = {
    Name = "${var.app_name}-${var.environment}-backend-eip"
  }
}
