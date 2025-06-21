# instance settings

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami                           = data.aws_ami.ubuntu.id
  instance_type                 = var.instance_type
  subnet_id                     = aws_subnet.public_1.id
  vpc_security_group_ids        = [aws_security_group.bastion-sg.id, aws_security_group.private-sg.id]
  associate_public_ip_address   = true
  key_name                      = var.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-public-1 (bastion)"
  }
}

resource "aws_instance" "public_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  key_name               = var.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-public-2"
  }
}

resource "aws_instance" "private_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  key_name               = var.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-private-1"
  }
}

resource "aws_instance" "private_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_2.id
  vpc_security_group_ids = [aws_security_group.private-sg.id]
  key_name               = var.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-private-2"
  }
}