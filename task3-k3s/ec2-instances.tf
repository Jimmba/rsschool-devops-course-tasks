# instances settings
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
  subnet_id                     = var.public_subnets[0].id
  vpc_security_group_ids        = [var.bastion-sg.id, var.private-sg.id]
  associate_public_ip_address   = true
  key_name                      = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-public-1 (bastion)"
  }

}

resource "aws_instance" "private_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnets[0].id
  vpc_security_group_ids = [var.private-sg.id]
  key_name               = aws_key_pair.k3s-key.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-private-1"
  }  
}


resource "aws_instance" "private_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnets[1].id
  vpc_security_group_ids = [var.private-sg.id]
  key_name               = aws_key_pair.k3s-key.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-private-2"
  }
}
