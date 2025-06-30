

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
      host        = var.private_1.private_ip
      private_key = var.k3s_key.private_key_pem
      bastion_host = var.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = var.private_1.id
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
      host        = var.private_1.private_ip
      private_key = var.k3s_key.private_key_pem
      bastion_host = var.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }

   triggers = {
    instance_id = var.private_1.id
  }
}

resource "null_resource" "download_k3s_config_to_bastion" {
  depends_on = [null_resource.copy_config]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/.kube",

      "scp -o StrictHostKeyChecking=no -i /home/ubuntu/k3s.pem ubuntu@${var.private_1.private_ip}:/home/ubuntu/config /home/ubuntu/config",
      "cp /home/ubuntu/config /home/ubuntu/.kube/config",
      "sed -i s/127.0.0.1/${var.private_1.private_ip}/ /home/ubuntu/.kube/config",
      "chmod 600 /home/ubuntu/.kube/config",
      "chown -R ubuntu:ubuntu /home/ubuntu/.kube",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = var.bastion.public_ip
      private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = var.bastion.id
  }
}

resource "null_resource" "install_kubectl_on_bastion" {
  depends_on = [null_resource.download_k3s_config_to_bastion]
  provisioner "remote-exec" {
    inline = [
      "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = var.bastion.public_ip
      private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = var.bastion.id
  }
}


resource "null_resource" "download_token" {
  depends_on = [ null_resource.install_k3s_server_on_private_1 ]
  provisioner "local-exec" {
    command = <<EOT
      ssh -o StrictHostKeyChecking=no -i keys/bastion.pem -A ubuntu@${var.bastion.public_ip} 'ssh -o StrictHostKeyChecking=no -i k3s.pem ubuntu@${var.private_1.private_ip} sudo cat /var/lib/rancher/k3s/server/node-token' > keys/k3s_token.txt
      EOT
  }

  triggers = {
    instance_id = var.private_1.id
  }
}

data "local_file" "k3s_token" {
  depends_on = [null_resource.download_token]
  filename   = "./keys/k3s_token.txt"
}

resource "null_resource" "install_worker_on_private_2" {
  depends_on = [ null_resource.wait_for_private_2_ssh, data.local_file.k3s_token ]

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | K3S_URL=https://${var.private_1.private_ip}:6443 K3S_TOKEN=${trimspace(data.local_file.k3s_token.content)} sh -"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = var.private_2.private_ip
      private_key = var.k3s_key.private_key_pem
      bastion_host = var.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = var.private_2.id
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
      host        = var.private_1.private_ip
      private_key = var.k3s_key.private_key_pem
      bastion_host = var.bastion.public_ip
      bastion_user = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    instance_id = var.private_2.id
  }
}