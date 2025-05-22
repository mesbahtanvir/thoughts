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
locals {
  ecr_repository_arn = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.app_name}-${var.environment}-backend"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Create a KMS key for CloudWatch Logs
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  tags = {
    Name        = "${var.app_name}-${var.environment}-cloudwatch-logs-key"
    Environment = var.environment
  }
}

# Create a CloudWatch log group for the instance with KMS encryption
resource "aws_cloudwatch_log_group" "instance_logs" {
  name              = "/aws/ec2/${var.app_name}-${var.environment}-instance"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn
  
  tags = {
    Name        = "${var.app_name}-${var.environment}-instance-logs"
    Environment = var.environment
  }
}

# IAM policy for ECR access
resource "aws_iam_role_policy" "ecr_pull_policy" {
  name = "${var.app_name}-${var.environment}-ecr-pull-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"  # This is required by ECR
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [local.ecr_repository_arn]
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = [data.aws_region.current.name]
          }
        }
      }
    ]
  })
}

# tfsec:ignore:aws-iam-no-policy-wildcards - CloudWatch Logs requires wildcard for log stream names
resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name = "${var.app_name}-${var.environment}-cloudwatch-logs-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.instance_logs.arn}:*"
      }
    ]
  })
}

# Allow the instance to create log groups in the specific path
resource "aws_iam_role_policy" "log_group_policy" {
  name = "${var.app_name}-${var.environment}-log-group-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/${var.app_name}-${var.environment}-*"
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

  # SSH access - restrict to specific IP
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # HTTP access - restricted to Load Balancer or specific IPs
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # HTTPS access - restricted to Load Balancer or specific IPs
  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # Allow HTTP outbound to specific AWS service endpoints
  egress {
    description = "Allow outbound HTTP traffic to AWS service endpoints"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    prefix_list_ids = [
      data.aws_ec2_managed_prefix_list.s3.id,
      data.aws_ec2_managed_prefix_list.ecr.id,
      data.aws_ec2_managed_prefix_list.ec2messages.id,
      data.aws_ec2_managed_prefix_list.ssm.id,
      data.aws_ec2_managed_prefix_list.ssmmessages.id
    ]
  }

  # Allow HTTPS outbound to specific AWS service endpoints
  egress {
    description = "Allow outbound HTTPS traffic to AWS service endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    prefix_list_ids = [
      data.aws_ec2_managed_prefix_list.s3.id,
      data.aws_ec2_managed_prefix_list.ecr.id,
      data.aws_ec2_managed_prefix_list.ec2messages.id,
      data.aws_ec2_managed_prefix_list.ssm.id,
      data.aws_ec2_managed_prefix_list.ssmmessages.id
    ]
  }

  # Allow NTP outbound
  # tfsec:ignore:aws-ec2-no-public-egress-sgr - NTP requires public internet access
  egress {
    description = "Allow outbound NTP traffic"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-backend-sg"
  }
}

# Create a KMS key for EBS encryption
resource "aws_kms_key" "ebs_key" {
  description             = "KMS key for ${var.app_name}-${var.environment} EBS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  tags = {
    Name        = "${var.app_name}-${var.environment}-ebs-key"
    Environment = var.environment
  }
}

# Create EC2 instance
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data = templatefile("${path.module}/user_data.sh", {
    app_name        = var.app_name
    environment     = var.environment
    github_token    = var.github_token
    jwt_secret      = var.jwt_secret
    GITHUB_USERNAME = var.github_username
  })

  tags = {
    Name = "${var.app_name}-${var.environment}-backend"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs_key.arn
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
