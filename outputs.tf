output "iam_roles" {
  value = module.task1-s3.iam_roles
}

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