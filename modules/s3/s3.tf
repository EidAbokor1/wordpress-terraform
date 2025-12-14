data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "wordpress_bucket" {
  bucket = "wordpress-media-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "wordpress-bucket"
    Environment = "wordpress"
  }
}

resource "aws_s3_bucket_public_access_block" "wordpress_bucket_pab" {
  bucket = aws_s3_bucket.wordpress_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}