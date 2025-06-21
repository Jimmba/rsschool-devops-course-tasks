resource "aws_iam_role" "github_actions" {
  name               = "GithubActionsRole-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_role.json
  tags = {
    Name = "devops-${terraform.workspace}-role"
  }
}
