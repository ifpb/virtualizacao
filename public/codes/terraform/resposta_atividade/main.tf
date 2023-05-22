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

resource "aws_security_group" "publico" {
  name        = "publico"
  description = "Acesso SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite accesso SSH de qualquer IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite accesso SSH de qualquer IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permite todo tráfego de saída
  }
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh.key_name

  security_groups = [aws_security_group.publico.name]

  connection {
      type = "ssh"
      private_key = file("~/.ssh/id_rsa")
      host = aws_instance.web.public_ip
      user = "centos"
    }

  provisioner "remote-exec" {
    inline = [
      ## corrigir repositórios do centos
      "sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*",
      "sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*",
      ## instalar o httpd
      "sudo yum update httpd -y",
      "sudo yum install -y httpd",
      "sudo service httpd start"
    ]
  }

  provisioner "local-exec" {
    command = <<EOH
                cat > index.html <<EOF
                <html>
                  <body><h1>Ola, Terraform!</h1></body>
                </html>
              EOH
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/index.html /var/www/html/index.html"
    ]
  }

  tags = {
    Name = "Terraform-Web-Instance"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}