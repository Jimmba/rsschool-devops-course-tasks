output "ec2-public-1" {
  value = {
    name          = aws_instance.bastion.tags["Name"]
    instance_type = aws_instance.bastion.instance_type
    public_ip     = aws_instance.bastion.public_ip
    private_ip    = aws_instance.bastion.private_ip
  }
}

# output "ec2-public-2" {
#   value = {
#     name          = aws_instance.public_2.tags["Name"]
#     instance_type = aws_instance.public_2.instance_type
#     public_ip     = aws_instance.public_2.public_ip
#     private_ip    = aws_instance.public_2.private_ip
#   }
# }

output "ec2-private-1" {
  value = {
    name          = aws_instance.private_1.tags["Name"]
    instance_type = aws_instance.private_1.instance_type
    private_ip    = aws_instance.private_1.private_ip
  }
}

output "ec2-private-2" {
  value = {
    name          = aws_instance.private_2.tags["Name"]
    instance_type = aws_instance.private_2.instance_type
    private_ip    = aws_instance.private_2.private_ip
  }
}