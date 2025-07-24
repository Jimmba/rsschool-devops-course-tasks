resource "null_resource" "create_monitoring_folder" {
  depends_on = [var.install_helm_id, var.install_jenkins_id]
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/monitoring",
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
    always_run = timestamp()
  }
}


resource "null_resource" "upload_monitoring_folder" {
  depends_on = [null_resource.create_monitoring_folder]
  provisioner "file" {
    source      = "./task7-monitoring/"
    destination = "/home/ubuntu/monitoring/"

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
    always_run = timestamp()
  }
}


resource "null_resource" "install_prometheus" {
  depends_on = [null_resource.upload_monitoring_folder]

  provisioner "remote-exec" {
    inline = [
      "echo add bitnami repo",
      "sudo helm repo add bitnami https://charts.bitnami.com/bitnami",
      "sudo helm repo update",

      "echo 'Install Prometheus...'",
      "sudo helm install prometheus bitnami/kube-prometheus -n monitoring --create-namespace -f monitoring/prometheus.yaml --kubeconfig /home/ubuntu/config",
      
      "echo 'Waiting for Prometheus pod to be Running...'",
      "while true; do",
      "  STATUS=$(sudo kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].status.phase}')",
      "  echo \"Status: $STATUS\"",
      "  if [ \"$STATUS\" = \"Running\" ]; then break; fi",
      "  sleep 10",
      "done",

      "echo 'Install Grafana...'",
      "sudo helm install grafana bitnami/grafana -n monitoring --create-namespace -f monitoring/grafana.yaml --kubeconfig /home/ubuntu/config",

      "echo 'Trying to forward port...'",
      "while true; do",
      "  nohup sudo kubectl port-forward svc/prometheus-operated -n monitoring 9090:9090 > /dev/null 2>&1 &",
      "  sleep 5",
      "  if ss -tln | grep -q ':9090'; then",
      "    echo 'Port-forward is running'",
      "    break",
      "  else",
      "    echo 'Port-forward failed, retrying...'",
      "    sudo pkill -f 'kubectl port-forward svc/prometheus-operated'",
      "  fi",
      "  sleep 5",
      "done",

      "echo 'Waiting for Grafana pod to be Running...'",
      "while true; do",
      "  STATUS=$(sudo kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].status.phase}')",
      "  echo \"Status: $STATUS\"",
      "  if [ \"$STATUS\" = \"Running\" ]; then break; fi",
      "  sleep 10",
      "done",

      "echo 'Trying to forward port...'",
      "while true; do",
      "  nohup sudo kubectl port-forward svc/grafana -n monitoring 3000:3000 > /dev/null 2>&1 &",
      "  sleep 5",
      "  if ss -tln | grep -q ':3000'; then",
      "    echo 'Port-forward is running'",
      "    break",
      "  else",
      "    echo 'Port-forward failed, retrying...'",
      "    sudo pkill -f 'kubectl port-forward svc/grafana'",
      "  fi",
      "  sleep 5",
      "done",
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
    always_run = timestamp()
  }
}