resource "null_resource" "copy_chart_files" {
  depends_on = [var.install_helm_id]
  provisioner "file" {
    source      = "./task5-application/flask-app-chart"
    destination = "/home/ubuntu/"

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

resource "null_resource" "install_flask_application" {
  depends_on = [null_resource.copy_chart_files]

  provisioner "remote-exec" {
    inline = [
      "echo 'Install Flask...'",
      "sudo helm uninstall flask-app -n flask-app || true",
      "sudo helm install flask-app ./flask-app-chart -n flask-app --create-namespace --kubeconfig /home/ubuntu/config",

      "echo 'Waiting for application pod to be Running...'",
      "while true; do",
      "  STATUS=$(sudo kubectl get pods -n flask-app -l app.kubernetes.io/name=flask-app-chart -o jsonpath='{.items[0].status.phase}')",
      "  echo \"Status: $STATUS\"",
      "  if [ \"$STATUS\" = \"Running\" ]; then break; fi",
      "  sleep 10",
      "done",

      "echo 'Trying to forward port...'",
      "while true; do",
      "  nohup sudo kubectl port-forward svc/flask-app-flask-app-chart -n flask-app 8081:8080 > /dev/null 2>&1 &",
      "  sleep 5",
      "  if ss -tln | grep -q ':8081'; then",
      "    echo 'Port-forward is running'",
      "    break",
      "  else",
      "    echo 'Port-forward failed, retrying...'",
      "    sudo pkill -f 'kubectl port-forward svc/flask-app-flask-app-chart'",
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
