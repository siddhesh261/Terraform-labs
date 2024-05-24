provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "key" {
  key_name   = "terraform-demo"
  public_key = file("C:/Users/HP/.ssh/id_rsa.pub")
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.example.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_instance" "vm" {
  ami                    = "ami-0bb84b8ffd87024d8"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.publicsubnet.id

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/HP/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "C:/terraform/provisioner/app.py"
    destination = "/home/ec2-user/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
    "sudo yum update -y",  # Update package lists (for CentOS/RHEL)
    "sudo yum install -y python3-pip",  # Install pip for Python 3
    "sudo pip3 install flask",  # Install Flask
    "cd /home/ec2-user",
    "sudo python3 app.py &",  # Start your application
    "sudo yum install -y httpd",  # Install Apache HTTP server (for CentOS/RHEL)
    "sudo systemctl start httpd",  # Start Apache HTTP server
    ]
  }
}
