provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "this" {
  for_each                    = var.instances
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  
  tags = merge(
    {
        "Name": each.key
    }, each.value.tags
  )
}

resource "tls_private_key" "rsa" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2_tofu"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_ssm_parameter" "private_key" {
  name        = "/dev/ssh/private_key"
  description = "Private SSH key for EC2"
  type        = "SecureString"
  value       = tls_private_key.rsa.private_key_openssh

  tags = {
    environment = "dev"
  }
}