
# Get current connected account ID from AWS
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions" {
  name = "GithubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement= [
        {
            Sid ="",
            Effect = "Allow",
            Principal = {
                AWS ="arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            Action = "sts:AssumeRole"
        }
    ]
  })
}
