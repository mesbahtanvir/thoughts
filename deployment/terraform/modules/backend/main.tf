# Create a security group for the EC2 instance
resource "aws_security_group" "backend_sg" {
  name_prefix = "thoughts-backend-sg"
  description = "Security group for backend EC2 instance"

  # Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
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
}

# Create the EC2 instance
resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  
  user_data = <<-EOF
              #!/bin/bash
              # Install Docker
              apt-get update
              apt-get install -y docker.io
              
              # Login to GitHub Container Registry
              echo "${var.github_token}" | docker login ghcr.io -u mesbahtanvir --password-stdin
              
              # Run the container
              docker run -d \
                --name thoughts-backend \
                -p 80:8000 \
                -e PORT=8000 \
                -e JWT_SECRET=${var.jwt_secret} \
                --restart always \
                ghcr.io/mesbahtanvir/thoughts-backend:latest
              EOF

  tags = {
    Name = "thoughts-backend"
  }
}

