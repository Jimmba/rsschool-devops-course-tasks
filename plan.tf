module "task1-s3" {
  source = "./task1-s3"
  region = var.region
}

module "task2-ec2" {
  source = "./task2-ec2"
  region = var.region
}

module "task3-k3s" {
  source          = "./task3-k3s"
  bastion_key     = module.task2-ec2.bastion_key
  k3s_key         = module.task2-ec2.k3s_key
  bastion         = module.task2-ec2.bastion
  private_1       = module.task2-ec2.private_1
  private_2       = module.task2-ec2.private_2
}