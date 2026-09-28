output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ecommerce.id
}

output "public_ip" {
  description = "Public IP address of the E-Commerce server"
  value       = aws_instance.ecommerce.public_ip
}

output "public_dns" {
  description = "Public DNS name of the E-Commerce server"
  value       = aws_instance.ecommerce.public_dns
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_instance.ecommerce.public_ip}"
}
