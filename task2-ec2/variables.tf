variable "region" {
  description = "AWS region for devops"
  type        = string
}


variable "instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default = "t3a.nano"
}

variable "key_name" {
  description = "AWS EC2 SSH key name"
  type        = string
  default     = "devops-key"
}