output "name" {
  value = aws_instance.web.tags.Name
}

output "public_ip" {
  value = aws_instance.web.public_ip
}