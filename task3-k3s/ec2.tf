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
}

resource "null_resource" "wait_for_bastion_ssh" {
  depends_on = [aws_instance.bastion]

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done",
      "echo 'Bastion is fully ready'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
      timeout     = "5m"
    }
  }

  triggers = {
    instance_id = aws_instance.bastion.id
  }
}

resource "null_resource" "install_k3s_key_on_bastion" {
  depends_on = [null_resource.wait_for_bastion_ssh]
  provisioner "file" {
    content     = tls_private_key.k3s-key.private_key_pem
    destination = "/home/ubuntu/k3s.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/k3s.pem",
     ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = aws_instance.bastion.id
  }
}

resource "null_resource" "wait_for_private_1_ssh" {
  depends_on = [null_resource.install_k3s_key_on_bastion, aws_instance.private_1]

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done",
      "echo 'Private_1 is fully ready'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.private_1.private_ip
      private_key = tls_private_key.k3s-key.private_key_pem
      bastion_host = aws_instance.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = tls_private_key.bastion_key.private_key_pem
      timeout     = "5m"
    }
  }

  triggers = {
    instance_id = aws_instance.private_1.id
  }
}

resource "null_resource" "wait_for_private_2_ssh" {
  depends_on = [null_resource.install_k3s_key_on_bastion, aws_instance.private_2]

  provisioner "remote-exec" {
    inline = [
     "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done",
      "echo 'Private_2 is fully ready'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.private_2.private_ip
      private_key = tls_private_key.k3s-key.private_key_pem
      bastion_host = aws_instance.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = tls_private_key.bastion_key.private_key_pem
      timeout     = "5m"
    }
  }

  triggers = {
    instance_id = aws_instance.private_2.id
  }
}

resource "null_resource" "install_k3s_server_on_private_1" {
  depends_on = [ null_resource.wait_for_private_1_ssh ]

  provisioner "remote-exec" {
    inline = [      
      "curl -sfL https://get.k3s.io | sh -",
      "echo `Waiting for K3s to be ready...`",
      "until sudo /usr/local/bin/k3s kubectl get nodes &>/dev/null; do sleep 5; done",
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

  triggers = {
    instance_id = aws_instance.private_1.id
  }
}

resource "null_resource" "copy_config" {
  depends_on = [null_resource.install_k3s_server_on_private_1]

  provisioner "remote-exec" {
    inline = [
      "until [ -f /etc/rancher/k3s/k3s.yaml ]; do echo 'Waiting for k3s.yaml...'; sleep 2; done",
      "sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/config",
      "sudo chown ubuntu:ubuntu /home/ubuntu/config"
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

   triggers = {
    instance_id = aws_instance.private_1.id
  }
}

resource "null_resource" "download_k3s_config_to_bastion_direct" {
  depends_on = [null_resource.copy_config]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/.kube",

      "scp -o StrictHostKeyChecking=no -i /home/ubuntu/k3s.pem ubuntu@${aws_instance.private_1.private_ip}:/home/ubuntu/config /home/ubuntu/config",
      "cp /home/ubuntu/config /home/ubuntu/.kube/config",
      # "chown ubuntu:ubuntu /home/ubuntu/.kube/config",
      "chmod 600 /home/ubuntu/.kube/config",
      "chown -R ubuntu:ubuntu /home/ubuntu/.kube",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = aws_instance.bastion.id
  }
}


resource "null_resource" "download_token" {
  depends_on = [ null_resource.install_k3s_server_on_private_1 ]
  provisioner "local-exec" {
    command = <<EOT
      ssh -o StrictHostKeyChecking=no -i keys/bastion.pem -A ubuntu@${aws_instance.bastion.public_ip} 'ssh -o StrictHostKeyChecking=no -i k3s.pem ubuntu@${aws_instance.private_1.private_ip} sudo cat /var/lib/rancher/k3s/server/node-token' > keys/k3s_token.txt
      EOT
  }

  triggers = {
    instance_id = aws_instance.private_1.id
  }
}

# resource "null_resource" "copy_token" {
#   depends_on = [ null_resource.get_token_and_config_from_server ]
#   provisioner "remote-exec" {
#     inline = [
#       "sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/config",
#       "sudo chown ubuntu:ubuntu /home/ubuntu/config"
#     ]
#    connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = aws_instance.private_1.private_ip
#       private_key = tls_private_key.k3s-key.private_key_pem
#       bastion_host = aws_instance.bastion.public_ip
#       bastion_user = "ubuntu"
#       bastion_private_key = tls_private_key.bastion_key.private_key_pem
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "scp -i k3s.pem ubuntu@${aws_instance.private_1}:/home/ubuntu/config ./config",
#       "sudo chown ubuntu:ubuntu /home/ubuntu/config"
#     ]
#    connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = aws_instance.bastion.public_ip
#       private_key = tls_private_key.bastion_key.private_key_pem
#     }
#   }
# }

data "local_file" "k3s_token" {
  depends_on = [null_resource.download_token]
  filename   = "./keys/k3s_token.txt"
}

# data "local_file" "config" {
#   depends_on = [null_resource.download_token_and_config_to_local]
#   filename   = "./keys/config"
# }

# resource "null_resource" "upload_config_to_bastion" {
#   depends_on = [ data.local_file.config ]

#    provisioner "file" {
#     source      = "./keys/config"
#     destination = "/home/ubuntu/.kube/config"

#     connection {
#       host        = aws_instance.bastion.public_ip
#       user        = "ubuntu"
#       private_key = tls_private_key.bastion_key.private_key_pem
#     }
#   }

#   triggers = {
#     instance_id = aws_instance.private_1.id
#   }
# }

resource "null_resource" "install_worker_on_private_2" {
  depends_on = [ null_resource.wait_for_private_2_ssh, data.local_file.k3s_token ]

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${aws_instance.private_1.private_ip}:6443 K3S_TOKEN=${trimspace(data.local_file.k3s_token.content)} sh -"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.private_2.private_ip
      private_key = tls_private_key.k3s-key.private_key_pem
      bastion_host = aws_instance.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = tls_private_key.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = aws_instance.private_2.id
  }
}

resource "null_resource" "install_kubectl_on_bastion" {
  depends_on = [null_resource.download_k3s_config_to_bastion_direct]
  provisioner "remote-exec" {
    inline = [
      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "sed -i s/127.0.0.1/${aws_instance.private_1.private_ip}/ /home/ubuntu/.kube/config"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.bastion.public_ip
      private_key = tls_private_key.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = aws_instance.bastion.id
  }
}

resource "null_resource" "pox_nginx" {
  depends_on = [ null_resource.install_worker_on_private_2 ]
  provisioner "remote-exec" {
    inline = [
      "sudo k3s kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml"
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

  triggers = {
    instance_id = aws_instance.private_2.id
  }
}