
resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "null_resource" "install_k3s_server_on_private_1" {
  depends_on = [ null_resource.wait_for_private_1_ssh ]

  provisioner "remote-exec" {
    inline = [      
      "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -",
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

resource "null_resource" "upload_jenkins_cluster_admin_roles" {
  depends_on = [null_resource.install_kubectl_on_bastion]

  provisioner "file" {
    source      = "task3-k3s/jenkins-cluster-admin.yaml"
    destination = "/home/ubuntu/jenkins-cluster-admin.yaml"

   connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = var.bastion.public_ip
      private_key = var.bastion_key.private_key_pem
    }
  }
  
  triggers = {
    private_1_id = var.private_1.id
  }
}

resource "null_resource" "apply_jenkins_cluster_admin_roles" {
  depends_on = [null_resource.upload_jenkins_cluster_admin_roles]
  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f jenkins-cluster-admin.yaml",
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

resource "null_resource" "install_docker_on_worker" {
  depends_on = [null_resource.wait_for_private_2_ssh]
  provisioner "remote-exec" {
    inline = [
        "curl -fsSL https://get.docker.com | sh",
        "sudo usermod -aG docker $USER",
        "sudo systemctl enable docker",
        "sudo systemctl start docker"
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = var.private_2.private_ip
      private_key         = var.k3s_key.private_key_pem
      bastion_host        = var.bastion.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    private_1_id = var.private_1.id
    private_2_id = var.private_2.id
  }
}


resource "null_resource" "install_worker_on_private_2" {
  depends_on = [ null_resource.install_docker_on_worker ]

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | sh -s - agent --server https://${var.private_1.private_ip}:6443 --token ${random_password.k3s_token.result} --node-label jenkins-agent=worker"
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
