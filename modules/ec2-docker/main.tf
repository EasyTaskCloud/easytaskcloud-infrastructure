# -------------------------
# Amazon Linux 2 AMI (latest)
# -------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------
# IAM ROLE für SSM
# -------------------------
resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -------------------------
# EC2 PUBLIC (Web)
# -------------------------
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = element(var.public_subnet_ids, 0)
  vpc_security_group_ids = [var.web_sg_id]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 nginx
              EOF

  tags = { Name = "${var.project_name}-web" }
}

# -------------------------
# EC2 PRIVATE (App/Backend)
# -------------------------
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = element(var.private_subnet_ids, 0)
  vpc_security_group_ids = [var.app_sg_id]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 8080:8080 your-backend-image
              EOF

  tags = { Name = "${var.project_name}-app" }
}

# -------------------------
# IAM INSTANCE PROFILE
# -------------------------
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# -------------------------
# ALB Target Group Attachment
# -------------------------
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.web.id
  port             = 80
}