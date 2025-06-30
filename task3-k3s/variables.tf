# variable "region" {
#   description = "AWS region for devops"
#   type        = string
# }

# variable "public_subnets" {
#   description = "List of public subnets (objects with id, name, cidr)"
#   type = list(object({
#     id   = string
#     name = string
#     cidr = string
#   }))
# }

# variable "private_subnets" {
#   description = "List of public subnets (objects with id, name, cidr)"
#   type = list(object({
#     id   = string
#     name = string
#     cidr = string
#   }))
# }

# variable "bastion-sg" {
#   type = object({
#     id          = string
#     name        = string
#     description = string
#     ingress     = any
#     egress      = any
#   })
# }

# variable "private-sg" {
#   type = object({
#     id          = string
#     name        = string
#     description = string
#     ingress     = any
#     egress      = any
#   })
# }

# variable "instance_type" {
#   description = "AWS EC2 instance type"
#   type        = string
#   default     = "t3a.medium"
# }

variable "bastion_key" {
  type = object({
    private_key_pem  = string
  })
}

variable "k3s_key" {
  type = object({
    private_key_pem  = string
  })
}

variable "bastion" {
  type = object({
    id          = string
    public_ip   = string
    private_ip  = string
  })
}

variable "private_1" {
  type = object({
    id          = string
    private_ip  = string
  })
}

variable "private_2" {
  type = object({
    id          = string
    private_ip  = string
  })
}