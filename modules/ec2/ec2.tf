data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Read cloud-init file and replace variables
locals {
  cloud_init_content = templatefile("${path.module}/cloud-init-files/wordpress.yaml", {
    db_name     = "mydb"
    db_username = var.db_username
    db_password = var.db_password
    db_endpoint = var.rds_endpoint
  })
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  associate_public_ip_address = true

  # Use cloud-init YAML file
  user_data = base64encode(local.cloud_init_content)

  tags = {
    Name = "wordpress-web-server"
  }
}