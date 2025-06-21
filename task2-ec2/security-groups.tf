resource "aws_security_group" "bastion-sg" {
  name = "bastion-sg"
  description = "Allow SSH access to bastion host"
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "devops-${terraform.workspace}-bastion-sg"
  }

  ingress {
    description = "SSH from anywhere"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-sg" {
  name        = "private-sg"
  description = "Allow SSH from bastion only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "devops-${terraform.workspace}-private-sg"
  }

  ingress {
    description = "Incoming traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "Outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}