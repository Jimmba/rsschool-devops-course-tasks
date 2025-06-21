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

output "bastion_sg" {
  value = {
    id          = aws_security_group.bastion_sg.id
    name        = aws_security_group.bastion_sg.tags["Name"]
    description = aws_security_group.bastion_sg.description
    ingress     = aws_security_group.bastion_sg.ingress
    egress      = aws_security_group.bastion_sg.egress
  }
}

output "private_sg" {
  value = {
    id          = aws_security_group.private_sg.id
    name        = aws_security_group.private_sg.tags["Name"]
    description = aws_security_group.private_sg.description
    ingress     = aws_security_group.private_sg.ingress
    egress      = aws_security_group.private_sg.egress
  }
}

output "ec2-public-1" {
  value = {
    name          = aws_instance.bastion.tags["Name"]
    instance_type = aws_instance.bastion.instance_type
    public_ip     = aws_instance.bastion.public_ip
    private_ip    = aws_instance.bastion.private_ip
  }
}

output "ec2-public-2" {
  value = {
    name          = aws_instance.public_2.tags["Name"]
    instance_type = aws_instance.public_2.instance_type
    public_ip     = aws_instance.public_2.public_ip
    private_ip    = aws_instance.public_2.private_ip
  }
}

output "ec2-private-1" {
  value = {
    name          = aws_instance.private_1.tags["Name"]
    instance_type = aws_instance.private_1.instance_type
    private_ip    = aws_instance.private_1.private_ip
  }
}

output "ec2-private-2" {
  value = {
    name          = aws_instance.private_2.tags["Name"]
    instance_type = aws_instance.private_2.instance_type
    private_ip    = aws_instance.private_2.private_ip
  }
}