# WordPress Terraform Infrastructure

A complete AWS infrastructure for WordPress using Terraform.

## Architecture

- VPC with public/private subnets across 2 AZs
- EC2 instance running Apache, PHP, and WordPress
- RDS MySQL database
- Application Load Balancer
- CloudFront CDN
- Route53 DNS
- S3 for media storage

## Prerequisites

- Terraform
- AWS CLI configured with credentials
- AWS Account

## Deployment
```bash
terraform init
terraform plan
terraform apply
```

## Access WordPress
```bash
terraform output cloudfront_domain_name
```

## After DNS Propagation
```bash
https://yourdomain.com
```

## Cleanup
```bash
terraform destroy
```

## Variables

Update `variables.tf` with your values:
- `aws_region` - AWS region
- `db_password` - RDS password
- `db_username` - RDS username (default: admin)
