# rsschool-devops-course-tasks

! notes: project works with eu-west-1 region and bucket `rs-devops-terrafrom-state`. If you want to change it, you should find and replace in all the project manually (because `backend` doesn't support variables - they are hardcoded)

1. Clone repository and change branch to task_1. Check - your repository should be named `rsschool-devops-course-tasks`
2. Install AWS CLI and terraform 1.12.0
3. Update default values in `variables.tf`
4. Create s3 backet named `rs-devops-terrafrom-state` and user with necessary policies.
5. Change data in `backend.tf`
6. Run `terraform init`, `terrafrom plan` and `terraform apply`.

If you want to run Github Actions:

1. Set variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (credentials of created user) in Github (Settings - Secrets and variables - Actions - New repository secrets). It should allow to connect Github to your AWS account.
2. Save changes, push commit and merge to 'main' branch.
