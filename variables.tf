variable "region" {
  description = "AWS region for devops"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for storing Terraform state"
  type        = string
  default     = "rs-devops-terrafrom-state"
}

variable "github_owner" {
  type    = string
  default = "Jimmba"
}

variable "github_repo" {
  type    = string
  default = "rsschool-devops-course-tasks"
}
