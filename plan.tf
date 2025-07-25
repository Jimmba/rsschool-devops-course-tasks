module "task1-s3" {
  source = "./task1-s3"
  region = var.region
}

module "task2-ec2" {
  source = "./task2-ec2"
  region = var.region
}

module "task3-k3s" {
  source      = "./task3-k3s"
  bastion_key = module.task2-ec2.bastion_key
  k3s_key     = module.task2-ec2.k3s_key
  bastion     = module.task2-ec2.bastion
  private_1   = module.task2-ec2.private_1
  private_2   = module.task2-ec2.private_2
}

module "task4-jenkins" {
  source                         = "./task4-jenkins"
  install_worker_on_private_2_id = module.task3-k3s.install_worker_on_private_2_id
  bastion_key                    = module.task2-ec2.bastion_key
  k3s_key                        = module.task2-ec2.k3s_key
  bastion                        = module.task2-ec2.bastion
  private_1                      = module.task2-ec2.private_1
  private_2                      = module.task2-ec2.private_2
}

module "task5-application" {
  source          = "./task5-application"
  bastion_key     = module.task2-ec2.bastion_key
  k3s_key         = module.task2-ec2.k3s_key
  bastion         = module.task2-ec2.bastion
  private_1       = module.task2-ec2.private_1
  install_helm_id = module.task4-jenkins.install_helm_id
  private_2       = module.task2-ec2.private_2
}

module "task7-monitoring" {
  source              = "./task7-monitoring"
  bastion_key         = module.task2-ec2.bastion_key
  k3s_key             = module.task2-ec2.k3s_key
  bastion             = module.task2-ec2.bastion
  private_1           = module.task2-ec2.private_1
  install_helm_id     = module.task4-jenkins.install_helm_id
  install_jenkins_id  = module.task4-jenkins.install_jenkins_id
  private_2           = module.task2-ec2.private_2
}