module "task1-s3" {
  source = "./task1-s3"
  region = var.region
}

module "task2-ec2" {
  source = "./task2-ec2"
  region = var.region
}