resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "local_file" "bastion_private_key" {
  filename = "${path.module}/../keys/bastion.pem"
  content  = tls_private_key.bastion_key.private_key_pem
  file_permission = "0600"
}

resource "tls_private_key" "k3s-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "k3s-key" {
  key_name   = "k3s"
  public_key = tls_private_key.k3s-key.public_key_openssh
}