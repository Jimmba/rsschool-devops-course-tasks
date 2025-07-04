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

### Installing kubernetis cluster:

You shouldn't do something specific. `Terraform apply` will prepare all infrastructure.
Keys to the bastion and internal resources are different. Key to the bastion is on `keys/bastion.pem`.
Config to connect to the cluster from your local PC and key to internal resources (other instances in AWS) are saved on the bastion (`/home/ubuntu/k3s.pem`, `/home/ubuntu/config`).
`kubectl` is installed on the bastion.
instance `private_1` is k3s server (control plane)
instance `private_2` is k3s node (worker)

## How to use infrastructure:

1. To connect to the bastion use command:
   `ssh -i keys/bastion.pem ubuntu@<BASTION_PUBLIC_IP>`
2. To connect to the other resources from the bastion use:
   `ssh -i k3s.pem ubuntu@<INTERNAL_PRIVATE_IP>`
3. To connect to the cluster locally you need:

- [install kubectl](https://kubernetes.io/docs/tasks/tools/)
- download config using command `scp -i keys/bastion.pem ubuntu@<BASTION_PUBLIC_IP>:/home/ubuntu/config ./config`.
- open the tunnel `ssh -i keys/bastion.pem -L 6443:<K3S_SERVER_IP>:6443 ubuntu@<BASTION_PUBLIC_IP>`

## Jenkins using Minikube

1. Install [Helm](https://helm.sh/docs/intro/install/)
2. Install [Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download)
3. Start cluster `minikube start`.
4. Add Jenkins to Helm repo

```bash
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
```

5. Create namespace and apply PV and PVC:

```bash
kubectl create namespace jenkins
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
```

6. Install Jenkins:

```bash
helm install jenkins jenkinsci/jenkins -n jenkins -f values.yaml
```

[Jenkins](https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3) 7. Redirect port

```
kubectl port-forward svc/jenkins -n jenkins 8080:8080
```

8. Use `http://localhost:8080` to open Jenkins web-page
   credentials (set in values.yaml):
   user: admin;
   password: admin_password
