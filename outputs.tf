output "ec2_public_ip" {
  value       = module.ec2.ec2_public_ip
  description = "Public IP of EC2 instance"
}

output "ec2_instance_id" {
  value       = module.ec2.instance_id
  description = "EC2 instance ID"
}

output "ec2_private_ip" {
  value       = module.ec2.ec2_private_ip
  description = "Private IP of EC2 instance"
}

output "alb_dns_name" {
  value       = module.alb.alb_domain_name
  description = "DNS name of the load balancer"
}

output "ssh_command" {
  value       = "ssh -i your-key.pem ec2-user@${module.ec2.ec2_public_ip}"
  description = "SSH command to connect to EC2"
}

output "wordpress_url" {
  value       = "http://${module.alb.alb_domain_name}"
  description = "WordPress URL via ALB"
}