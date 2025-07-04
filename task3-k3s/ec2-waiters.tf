
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