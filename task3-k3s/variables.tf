variable "region" {
  description = "AWS region for devops"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets (objects with id, name, cidr)"
  type = list(object({
    id   = string
    name = string
    cidr = string
  }))
}

variable "private_subnets" {
  description = "List of public subnets (objects with id, name, cidr)"
  type = list(object({
    id   = string
    name = string
    cidr = string
  }))
}

variable "bastion-sg" {
  type = object({
    id          = string
    name        = string
    description = string
    ingress     = any
    egress      = any
  })
}

variable "private-sg" {
  type = object({
    id          = string
    name        = string
    description = string
    ingress     = any
    egress      = any
  })
}

variable "instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default = "t3a.medium"
}
