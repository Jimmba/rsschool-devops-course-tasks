resource "null_resource" "create_jenkins_folder" {
  depends_on = [var.install_worker_on_private_2_id]
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/jenkins",
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = var.private_1.private_ip
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


data "local_file" "pv" {
  filename   = "task4-jenkins/pv.yaml"
}

data "local_file" "pvc" {
  filename   = "task4-jenkins/pvc.yaml"
}

data "local_file" "values" {
  filename   = "task4-jenkins/values.yaml"
}

resource "null_resource" "upload_jenkins_pv" {
  depends_on = [null_resource.create_jenkins_folder]

  provisioner "file" {
    source      = "task4-jenkins/pv.yaml"
    destination = "/home/ubuntu/jenkins/pv.yaml"

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = var.private_1.private_ip
      private_key         = var.k3s_key.private_key_pem
      bastion_host        = var.bastion.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }
  
  triggers = {
    private_1_id = var.private_1.id
  }
}

resource "null_resource" "upload_jenkins_pvc" {
  depends_on = [null_resource.create_jenkins_folder]

  provisioner "file" {
    source      = "task4-jenkins/pvc.yaml"
    destination = "/home/ubuntu/jenkins/pvc.yaml"

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = var.private_1.private_ip
      private_key         = var.k3s_key.private_key_pem
      bastion_host        = var.bastion.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    private_1_id = var.private_1.id
  }
}

resource "null_resource" "upload_jenkins_values" {
  depends_on = [null_resource.create_jenkins_folder]

  provisioner "file" {
    source      = "task4-jenkins/values.yaml"
    destination = "/home/ubuntu/jenkins/values.yaml"

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = var.private_1.private_ip
      private_key         = var.k3s_key.private_key_pem
      bastion_host        = var.bastion.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = var.bastion_key.private_key_pem
    }
  }

  triggers = {
    private_1_id = var.private_1.id
  }
}

resource "null_resource" "install_helm" {
  depends_on = [null_resource.upload_jenkins_pv, null_resource.upload_jenkins_pvc, null_resource.upload_jenkins_values]

  provisioner "remote-exec" {
    inline = [
      "echo 'Install Helm...'",
      "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
      "chmod 700 get_helm.sh",
      "./get_helm.sh",

      "sudo helm repo add jenkinsci https://charts.jenkins.io",
      "sudo helm repo update",
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = var.private_1.private_ip
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

resource "null_resource" "install_jenkins" {
  depends_on = [null_resource.install_helm]

  provisioner "remote-exec" {
    inline = [
      "echo 'Create namespace...'",
      "sudo kubectl create namespace jenkins || true",
      "until sudo kubectl get ns jenkins; do echo 'Waiting for namespace...'; sleep 2; done",
      
      "echo 'Apply pv, pvc...'",
      "sudo kubectl apply -f /home/ubuntu/jenkins/pv.yaml || true",
      "sudo kubectl apply -f /home/ubuntu/jenkins/pvc.yaml || true",

      "echo 'Install Jenkins...'",
      "sudo helm uninstall jenkins -n jenkins || true",
      "sudo helm install jenkins jenkinsci/jenkins -n jenkins -f /home/ubuntu/jenkins/values.yaml --kubeconfig /home/ubuntu/config",

      "echo 'Waiting for Jenkins pod to be Running...'",
      "while true; do",
      "  STATUS=$(sudo kubectl get pods -n jenkins -l app.kubernetes.io/component=jenkins-controller -o jsonpath='{.items[0].status.phase}')",
      "  echo \"Status: $STATUS\"",
      "  if [ \"$STATUS\" = \"Running\" ]; then break; fi",
      "  sleep 10",
      "done",

      "echo 'Trying to forward port...'",
      "while true; do",
      "  nohup sudo kubectl port-forward svc/jenkins -n jenkins 8080:8080 > /dev/null 2>&1 &",
      "  sleep 5",
      "  if ss -tln | grep -q ':8080'; then",
      "    echo 'Port-forward is running'",
      "    break",
      "  else",
      "    echo 'Port-forward failed, retrying...'",
      "    sudo pkill -f 'kubectl port-forward svc/jenkins'",
      "  fi",
      "  sleep 5",
      "done"
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = var.private_1.private_ip
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
