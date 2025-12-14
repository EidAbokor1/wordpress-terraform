resource "aws_db_subnet_group" "wordpress-subnet-group" {
  name        = "wordpress-subnet-group"
  description = "Subnet group for WordPress RDS instance"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "wordpress-subnet-group"
  }
}

resource "aws_db_instance" "rds-instance" {
  db_subnet_group_name = aws_db_subnet_group.wordpress-subnet-group.name
  vpc_security_group_ids = [var.rds_sg_id] 

  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  tags = {
    Name = "wordpress-db"
  }
}