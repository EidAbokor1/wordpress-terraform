output "bucket_name" {
  value = aws_s3_bucket.wordpress_bucket.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.wordpress_bucket.bucket_regional_domain_name
}

variable "aws_account_id" {
  type = string
}