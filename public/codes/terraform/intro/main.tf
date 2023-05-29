terraform {
  backend "s3" {
    bucket = "virt-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "ssh" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh.key_name

  tags = {
    Name = "Terraform-Web-Instance"
  }
}
