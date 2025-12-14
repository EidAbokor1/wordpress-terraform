resource "aws_route53_zone" "wordpress_zone" {
    name = var.wordpress_zone
}

resource "aws_route53_record" "wordpress" {
  zone_id = aws_route53_zone.wordpress_zone.zone_id
  name    = "eiddev.xyz"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}