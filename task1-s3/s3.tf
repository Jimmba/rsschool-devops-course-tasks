# resource "aws_s3_bucket" "terraform_state" {
#   bucket        = var.bucket_name
#   force_destroy = true


#   tags = {
#     Name = "Terraform State"
#   }
# }

# resource "aws_s3_bucket_versioning" "state_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id

#   versioning_configuration {
#     status = "Suspended" # Change to Enable in production
#   }
# }
