provider "aws" {

    region = "us-east-1"
  
}

module "instance" {
    source = "../tf2/modules/ec2"
    ami="ami-0bb84b8ffd87024d8"
    instance_type="t2.micro"

}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-tf-test-bucket-5232024"
}

resource "aws_dynamodb_table" "terraformlock" {
    name = "terraformlock"
    billing_mode = "Pay_per_request"
    hash_key = "LockID"

    attribute {
      name= "LockID"
      type = "S"
    }
  
}
