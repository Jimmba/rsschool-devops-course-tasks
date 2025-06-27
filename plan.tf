module "task1-s3" {
  source = "./task1-s3"
  region = var.region
}

module "task2-ec2" {
  source = "./task2-ec2"
  region = var.region
}

module "task3-k3s" {
  source = "./task3-k3s"
  region = var.region
  public_subnets = module.task2-ec2.public_subnets
  private_subnets = module.task2-ec2.private_subnets
  bastion-sg = module.task2-ec2.bastion-sg
  private-sg = module.task2-ec2.private-sg
}