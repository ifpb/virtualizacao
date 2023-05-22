variable "ami" {
    description = "The AMI to use"
}

variable "aws_region" {
    description = "The AWS region to use"
}

variable "instance_type" {
  default = "t2.micro"
  description = "The type of EC2 instance to launch"
}