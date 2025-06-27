output "vpc_id" {
  value = module.task2-ec2.vpc_id
}

output "public_subnets" {
  value = module.task2-ec2.public_subnets
}

output "private_subnets" {
  value = module.task2-ec2.private_subnets
}

output "internet_gateway_id" {
  value = module.task2-ec2.internet_gateway_id
}

output "nat_eip_id" {
  value = module.task2-ec2.nat_eip_id
}

output "nat_gateway_id" {
  value = module.task2-ec2.nat_gateway_id
}

output "bastion-sg" {
  value = module.task2-ec2.bastion-sg
}
output "private-sg" {
  value = module.task2-ec2.private-sg
}
output "ec2-public-1" {
  value = module.task2-ec2.ec2-public-1
}
output "ec2-public-2" {
  value = module.task2-ec2.ec2-public-2
}
output "ec2-private-1" {
  value = module.task2-ec2.ec2-private-1
}
output "ec2-private-2" {
  value = module.task2-ec2.ec2-private-2
}