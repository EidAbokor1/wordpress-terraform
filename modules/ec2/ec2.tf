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

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e
              yum update -y
              yum install -y httpd php php-mysqlnd php-pdo php-gd php-mbstring php-xml wget unzip
              
              systemctl start httpd
              systemctl enable httpd
              
              mkdir -p /var/www/html
              
              cd /tmp
              wget https://wordpress.org/latest.zip
              unzip -o latest.zip
              rm -rf /var/www/html/*
              cp -r wordpress/* /var/www/html/
              rm -f /var/www/html/index.html
              chown -R apache:apache /var/www/html
              chmod -R 755 /var/www/html
              
              cd /var/www/html
              cp wp-config-sample.php wp-config.php
              sed -i "s/database_name_here/mydb/g" wp-config.php
              sed -i "s/username_here/${var.db_username}/g" wp-config.php
              sed -i "s/password_here/${var.db_password}/g" wp-config.php
              sed -i "s/localhost/${var.rds_endpoint}/g" wp-config.php
              
              systemctl restart httpd
              EOF
  )

  tags = {
    Name = "wordpress-web-server"
  }
}