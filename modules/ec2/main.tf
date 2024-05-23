resource "aws_instance" "machine" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
  
}