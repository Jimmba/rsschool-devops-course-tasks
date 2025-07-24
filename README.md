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

### How to use infrastructure:

1. To connect to the bastion use command:
   `ssh -i keys/bastion.pem ubuntu@<BASTION_PUBLIC_IP>`
2. To connect to the other resources from the bastion use:
   `ssh -i k3s.pem ubuntu@<INTERNAL_PRIVATE_IP>`
3. To connect to the cluster locally you need:

- [install kubectl](https://kubernetes.io/docs/tasks/tools/)
- download config using command `scp -i keys/bastion.pem ubuntu@<BASTION_PUBLIC_IP>:/home/ubuntu/config ./config`.
- open the tunnel `ssh -i keys/bastion.pem -L 6443:<K3S_SERVER_IP>:6443 ubuntu@<BASTION_PUBLIC_IP>`

## Jenkins

There are two methods to run Jenkins:

1. In AWS cloud
2. Locally using `minikube`

### Jenkins in AWS

After `terraform apply` jenkins deploys on `private-1` ec2 instance. To get access to it you should use port-forwardings:

1. Run `ssh -i keys/bastion.pem -L 8080:localhost:8080 ubuntu@<BASTION_PUBLIC_IP>` to open the tunnel to the bastion
2. Run `ssh -i k3s.pem -L 8080:localhost:8080 ubuntu@<K3S_SERVER_IP>` to open the tunnel from the bastion to the jenkins
3. Use `http://localhost:8080` to open Jenkins web-page
4. Use credentials (set in values.yaml):
   user: admin;
   password: admin_password

### Jenkins using Minikube

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
kubectl apply -f task4-jenkins/pv.yaml
kubectl apply -f task4-jenkins/pvc.yaml
```

6. Install Jenkins:

```bash
helm install jenkins jenkinsci/jenkins -n jenkins -f task4-jenkins/values.yaml
```

[Jenkins](https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3)

```
kubectl port-forward svc/jenkins -n jenkins 8080:8080
```

8. Use `http://localhost:8080` to open Jenkins web-page
9. Use credentials (set in values.yaml):
   user: admin;
   password: admin_password

## Simple application deployment with Helm

There are two methods to run Jenkins:

1. In AWS cloud
2. Locally using `minikube`

### Application in AWS

After `terraform apply` applications deploys on `private-1` ec2 instance. To get access to it you should use port-forwardings:

1. Run `ssh -i keys/bastion.pem -L 8081:localhost:8081 ubuntu@<BASTION_PUBLIC_IP>` to open the tunnel to the bastion
2. Run `ssh -i k3s.pem -L 8081:localhost:8081 ubuntu@<K3S_SERVER_IP>` to open the tunnel from the bastion to the application
3. Use `http://localhost:8081` to open application web-page
   (if you want to use another port you should update chart congiguration)

### Install application using Minikube

1. Install Minikube and Jenkins (see instructions above)
2. Install application:

```
helm install flask-app ./task5-application/flask-app-chart -n flask-app --create-namespace
```

3. Forward port to your local machine. Make sure that port is not busy or select another port:

```
kubectl port-forward svc/flask-app -n flask-app 8081:8080
```

4. Your application is available at the address `http://127.0.0.1:8081` (change port if you need)

## Pipeline

1. Open jenkins in browser (read above how to install it and forward port)

2. Add credentials to Jenkins
   Jenkins - Manage Jenkinks - Credentials - System - Global Credentials:

2.1 Add `DockerHub` credentials:

- kind: username and password
- username: YOUR DOCKERHUB NAME
- password: YOUR DOCKERHUB TOKEN
- id: `docker-hub-credentials` (this value should be used in jenkins configuration as `credentialsId` value)
  press `create` button

  2.2 Add `SonarQube` token:

- kind: secret text
- secret: YOUR SONARQUBE TOKEN
- id: `sonar-token`
  press `create` button

  2.3 Add `email` to secret:

- kind: secret text
- secret: YOUR EMAIL
- id: `email-to`

3. Configure email notification agent:
   Go to `manage jenkins - system - email notification` and set:
   SMTP server: `smtp.gmail.com`
   set `use smtp authentification`
   username: `YOUR_MAIL_LOGIN`
   password: `YOUR_PASSWORD` ([application password](https://myaccount.google.com/apppasswords))
   set `use ssl`
   SMTP port: 465

4. Push new commit in `main` or run pipeline manually.

## Configure pipeline manually (not needed. Only for information)

1. Build/deploy jenkins agent and update image name in Jenkinsfile - it is used during the pipeline

```
docker build -t <YOUR_DOCKERHUB_NAME>/jenkins-agent:latest ./task6-pipeline
docker push <YOUR_DOCKERHUB_NAME>/jenkins-agent:latest
```

2. Create new pipeline:

- press `Create new item`
- enter the name (ex. flask-app)
- press `Pipeline`
- press `OK` button

3. Configure pipeline. Set:

- Definition: select Pipeline script from SCM.
- SCM select Git.
- Repository URL: enter the URL of Git repository (ex: `https://github.com/Jimmba/rsschool-devops-course-tasks`).
- Branch Specifier: specify `main`
- Script Path: leave as Jenkinsfile (if it's in the root) or specify the path if it’s in a subfolder.

## Monitoring

### Preparing:

1. Add namespace

```
kubectl create namespace monitoring
```

2. Add bitnami (if not added earlier):

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Prometheus manual installation

1. Install Prometheus:

```
helm install prometheus bitnami/kube-prometheus \
  -n monitoring -f task7-monitoring/prometheus.yaml
```

2. Check installation:

```
kubectl get all -n monitoring
```

3. Forward port:

```
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

### Grafana manual installation

1. Install Grafana:

```
helm repo add grafana https://grafana.github.io/helm-charts
kubectl apply -f task7-monitoring/pv.yaml
kubectl apply -f task7-monitoring/pvc.yaml
helm install grafana bitnami/grafana \
  -n monitoring -f task7-monitoring/grafana.yaml
```

2. Check installation:

```
kubectl get all -n monitoring
```

3. Forward port:

```
kubectl port-forward svc/grafana -n monitoring 3000:3000
```

4. Get password (if it isn't configured in the `task7-monitoring/grafana.yaml`):

```
echo "Password: $(kubectl get secret grafana-admin --namespace monitoring -o jsonpath="{.data.
GF_SECURITY_ADMIN_PASSWORD}" | base64 -d)"
```

5. Open Grafana `http://localhost:3000` using credentials:
   login: admin
   password: [PASSWORD_YOU_GOT_ON_STEP_4]
