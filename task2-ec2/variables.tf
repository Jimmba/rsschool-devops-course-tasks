variable "region" {
  description = "AWS region for devops"
  type        = string
}


variable "instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3a.medium"
}
