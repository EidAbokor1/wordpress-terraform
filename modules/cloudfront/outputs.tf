output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.wordpress.domain_name
}

output "cloudfront_zone_id" {
  value = aws_cloudfront_distribution.wordpress.hosted_zone_id
}