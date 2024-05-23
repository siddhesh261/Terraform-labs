provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
    source = "./modules/ec2"
    ami="ami-0bb84b8ffd87024d8"
    instance_type="t2.micro"
}
