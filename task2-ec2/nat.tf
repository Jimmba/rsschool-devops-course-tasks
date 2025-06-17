resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "devops-${terraform.workspace}-nat_eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id
  tags = {
    Name = "devops-${terraform.workspace}-main"
  }
}