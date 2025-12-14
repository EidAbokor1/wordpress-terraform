data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  ec2_sg_id = module.sg.ec2_sg_id
}

module "sg" {
  source = "./modules/sg"

  vpc_id = module.vpc.wordpress_vpc_id
}

module "rds" {
  source = "./modules/rds"

  subnet_ids = [
    module.vpc.private_subnet_a_id,
    module.vpc.private_subnet_b_id
  ]
  rds_sg_id = module.sg.rds_sg_id
  db_password = var.db_password
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "wordpress-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "wordpress-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy" "ssm_full_access" {
  name = "ssm-full-access"
  role = aws_iam_role.ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:*",
          "ssmmessages:*",
          "ec2messages:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
} 

module "ec2" {
  source = "./modules/ec2"
  
  subnet_id              = module.vpc.private_subnet_a_id
  security_group_id      = module.sg.ec2_sg_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  rds_endpoint           = module.rds.rds_endpoint
  db_username            = var.db_username
  db_password            = var.db_password
}

module "alb" {
  source = "./modules/alb"

  alb_sg_id         = module.sg.alb_sg_id
  public_subnet_ids = [
    module.vpc.public_subnet_a_id,
    module.vpc.public_subnet_b_id
  ]
  ec2_instance_id = module.ec2.instance_id
  vpc_id          = module.vpc.wordpress_vpc_id
}

module "s3" {
  source = "./modules/s3"
  bucket_name = "wordpress-media-${data.aws_caller_identity.current.account_id}"
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "cloudfront" {
  source = "./modules/cloudfront"

  alb_domain_name        = module.alb.alb_domain_name
  s3_bucket_domain_name  = module.s3.bucket_domain_name
}

module "route53" {
  source = "./modules/route53"

  wordpress_zone         = "eiddev.xyz"
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
  cloudfront_zone_id     = module.cloudfront.cloudfront_zone_id
}