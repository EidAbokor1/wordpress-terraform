resource "aws_vpc" "wordpress-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "wordpress-vpc"
  }
  
} 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress-igw"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.az-2a

  tags = {
    Name = "wordpress-public-subnet-a"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.az-2b

  tags = {
    Name = "wordpress-public-subnet-b"
  }
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.az-2a

  tags = {
    Name = "wordpress-private-subnet-a"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.az-2b

  tags = {
    Name = "wordpress-private-subnet-b"
  }
}

resource "aws_eip" "nat-eip-a" {
  domain = "vpc"
}

resource "aws_eip" "nat-eip-b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "rng" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  availability_mode = "regional"

  availability_zone_address {
    allocation_ids = [aws_eip.nat-eip-a.id]
    availability_zone = var.az-2a
  }

  availability_zone_address {
    allocation_ids = [aws_eip.nat-eip-b.id]
    availability_zone = var.az-2b
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.wordpress-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "wordpress-public-rt"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.wordpress-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.rng.id
  }

  tags = {
    Name = "wordpress-private-rt"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.wordpress-vpc.id
  service_name        = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  security_group_ids  = [var.ec2_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.wordpress-vpc.id
  service_name        = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  security_group_ids  = [var.ec2_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.wordpress-vpc.id
  service_name        = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  security_group_ids  = [var.ec2_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ec2messages-endpoint"
  }

}