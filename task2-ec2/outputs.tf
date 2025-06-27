output "vpc_id" {
  value = {
    id    = aws_vpc.main.id
    name  = aws_vpc.main.tags["Name"]
    cidr  = aws_vpc.main.cidr_block
  }
}

output "public_subnets" {
  value = [{
    id    = aws_subnet.public_1.id
    name  = aws_subnet.public_1.tags["Name"]
    cidr  = aws_subnet.public_1.cidr_block
  },
  {
    id    = aws_subnet.public_2.id
    name  = aws_subnet.public_2.tags["Name"]
    cidr  = aws_subnet.public_2.cidr_block
  }]
}

output "private_subnets" {
  value = [{
    id    = aws_subnet.private_1.id
    name  = aws_subnet.private_1.tags["Name"]
    cidr  = aws_subnet.private_1.cidr_block
  },
  {
    id    = aws_subnet.private_2.id
    name  = aws_subnet.private_2.tags["Name"]
    cidr  = aws_subnet.private_2.cidr_block
  }]
}

output "internet_gateway_id" {
  value = {
    id      = aws_internet_gateway.main.id
    name    = aws_internet_gateway.main.tags["Name"]
  }
}

output "nat_eip_id" {
  value = {
    id          = aws_eip.nat_eip.id
    name        = aws_eip.nat_eip.tags["Name"]
    private_ip  = aws_eip.nat_eip.private_ip
    public_ip   = aws_eip.nat_eip.public_ip
    public_dns  = aws_eip.nat_eip.public_dns
  }
}

output "nat_gateway_id" {
  value = {
    id              = aws_nat_gateway.main.id
    name            = aws_nat_gateway.main.tags["Name"]
    allocation_id   = aws_nat_gateway.main.allocation_id
    public_ip       = aws_nat_gateway.main.public_ip
    private_ip      = aws_nat_gateway.main.private_ip
    subnet_id       = aws_nat_gateway.main.subnet_id
  }
}

output "bastion-sg" {
  value = {
    id          = aws_security_group.bastion-sg.id
    name        = aws_security_group.bastion-sg.tags["Name"]
    description = aws_security_group.bastion-sg.description
    ingress     = aws_security_group.bastion-sg.ingress
    egress      = aws_security_group.bastion-sg.egress
  }
}

output "private-sg" {
  value = {
    id          = aws_security_group.private-sg.id
    name        = aws_security_group.private-sg.tags["Name"]
    description = aws_security_group.private-sg.description
    ingress     = aws_security_group.private-sg.ingress
    egress      = aws_security_group.private-sg.egress
  }
}
