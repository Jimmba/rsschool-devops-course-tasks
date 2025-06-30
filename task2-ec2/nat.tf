resource "null_resource" "nat-bastion" {
  depends_on = [aws_instance.bastion]

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c \"echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf\"",
      "sudo sysctl -p",
      "iface=$(ip -o -4 route show to default | awk '{print $5}')",
      "sudo iptables -t nat -A POSTROUTING -o $iface -s 0.0.0.0/0 -j MASQUERADE"
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