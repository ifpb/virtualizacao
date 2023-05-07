provider "aws" {
  region = "us-east-2"
}

resource "aws_key_pair" "ssh" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh.key_name

  tags = {
    Name = "Terraform-Web-Instance"
  }
}
