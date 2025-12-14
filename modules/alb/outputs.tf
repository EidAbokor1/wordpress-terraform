output "alb_domain_name" {
  value = aws_lb.alb.dns_name
}