# instances settings
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami                           = data.aws_ami.ubuntu.id
  instance_type                 = var.instance_type
  subnet_id                     = var.public_subnets[0].id
  vpc_security_group_ids        = [var.bastion-sg.id, var.private-sg.id]
  associate_public_ip_address   = true
  key_name                      = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-public-1 (bastion)"
  }

  provisioner "file" {
    content     = tls_private_key.k3s-key.private_key_pem
    destination = "/home/ubuntu/k3s.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/k3s.pem",
      "sudo apt-get update -y",
      "sudo apt-get install -y curl",
      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }
  }
}

# resource "aws_instance" "public_2" {
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.instance_type
#   subnet_id              = var.public_subnets[1].id
#   vpc_security_group_ids = [var.private-sg.id]
#   key_name               = aws_key_pair.k3s-key.key_name

#   tags = {
#     Name = "devops-${terraform.workspace}-ec2-public-2"
#   }
# }

resource "aws_instance" "private_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnets[0].id
  vpc_security_group_ids = [var.private-sg.id]
  key_name               = aws_key_pair.k3s-key.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-private-1"
  }

  user_data = <<-EOF
              #!/bin/bash
              curl -sfL https://get.k3s.io | sh -
              echo "Waiting for K3s to be ready..."
              until sudo /usr/local/bin/k3s kubectl get nodes &>/dev/null; do sleep 5; done

              echo "Applying test pod..."
              sudo /usr/local/bin/k3s kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
              EOF
}

resource "null_resource" "get_k3s_token" {
  depends_on = [aws_instance.private_1]

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for node-token...'",
      "until sudo test -f /var/lib/rancher/k3s/server/node-token; do sleep 5; done",
      "sudo cat /var/lib/rancher/k3s/server/node-token"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.private_1.private_ip
      private_key = tls_private_key.k3s-key.private_key_pem
      bastion_host = aws_instance.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = tls_private_key.bastion_key.private_key_pem
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh -o StrictHostKeyChecking=no -i keys/bastion.pem -A ubuntu@${aws_instance.bastion.public_ip} 'ssh -o StrictHostKeyChecking=no -i k3s.pem ubuntu@${aws_instance.private_1.private_ip} sudo cat /var/lib/rancher/k3s/server/node-token' > keys/k3s_token.txt
      EOT
  }
}

data "local_file" "k3s_token" {
  depends_on = [null_resource.get_k3s_token]
  filename   = "./keys/k3s_token.txt"
}

resource "aws_instance" "private_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnets[1].id
  vpc_security_group_ids = [var.private-sg.id]
  key_name               = aws_key_pair.k3s-key.key_name

  tags = {
    Name = "devops-${terraform.workspace}-ec2-private-2"
  }

  depends_on = [data.local_file.k3s_token]

  user_data = <<-EOF
              #!/bin/bash
              curl -sfL https://get.k3s.io | K3S_URL="https://${aws_instance.private_1.private_ip}:6443" K3S_TOKEN="${trimspace(data.local_file.k3s_token.content)}" sh -
              EOF
}