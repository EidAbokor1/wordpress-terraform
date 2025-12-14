resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "security group for ALB"
  vpc_id      = var.vpc_id

    ingress {
        description      = "Allow HTTP traffic from anywhere"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description      = "Allow HTTPS traffic from anywhere"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "security group for EC2 instances"
  vpc_id      = var.vpc_id

    ingress {
        description      = "Allow HTTP traffic from ALB"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        security_groups  = [aws_security_group.alb-sg.id]
    }

    ingress {
        description      = "Allow HTTPS traffic from ALB"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        security_groups  = [aws_security_group.alb-sg.id]
    }

    ingress {
    description = "Allow HTTPS from itself for VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "security group for RDS"
  vpc_id      = var.vpc_id

    ingress {
        description      = "Allow MySQL traffic from EC2 instances"
        from_port        = 3306
        to_port          = 3306
        protocol         = "tcp"
        security_groups  = [aws_security_group.ec2-sg.id]
    }

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "rds-sg"
  }
}