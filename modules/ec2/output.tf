output "public_ip" {

    value = aws_instance.machine.public_ip
  
}

output "Name" {
  value = aws_instance.machine.id
}