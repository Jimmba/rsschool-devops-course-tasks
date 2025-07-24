variable "install_helm_id" {
  type = string
}

variable "install_jenkins_id" {
  type = string
}

variable "private_1" {
  type = object({
    id         = string
    private_ip = string
  })
}

variable "private_2" {
  type = object({
    id         = string
    private_ip = string
  })
}

variable "k3s_key" {
  type = object({
    private_key_pem = string
  })
}

variable "bastion" {
  type = object({
    id         = string
    public_ip  = string
    private_ip = string
  })
}

variable "bastion_key" {
  type = object({
    private_key_pem = string
  })
}