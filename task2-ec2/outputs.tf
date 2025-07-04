output "bastion_key" {
  value = {
    private_key_pem = tls_private_key.bastion_key.private_key_pem
  }
}

output "k3s_key" {
  value = {
    private_key_pem = tls_private_key.k3s_key.private_key_pem
  }
}

output "bastion" {
  value = {
    id            = aws_instance.bastion.id
    public_ip     = aws_instance.bastion.public_ip
    private_ip    = aws_instance.bastion.private_ip
  }
}

output "private_1" {
  value = {
    id            = aws_instance.private_1.id
    private_ip    = aws_instance.private_1.private_ip
  }
}

output "private_2" {
  value = {
    id            = aws_instance.private_2.id
    instance_type = aws_instance.private_2.instance_type
    private_ip    = aws_instance.private_2.private_ip
  }
}