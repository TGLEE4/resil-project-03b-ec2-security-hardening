output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.web.dns_name
}

output "alb_url" {
  description = "HTTP URL for testing the Application Load Balancer."
  value       = "http://${aws_lb.web.dns_name}"
}

output "private_ec2_id" {
  description = "ID of the private EC2 instance."
  value       = aws_instance.web.id
}

output "private_ec2_private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.web.private_ip
}

output "vpc_id" {
  description = "ID of the custom VPC."
  value       = aws_vpc.main.id
}
