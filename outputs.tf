output "bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "github_role" {
  description = "Arn of the github actions role"
  value       = aws_iam_role.github_actions.arn
}
