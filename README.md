# Configs for bank-app terraform code and manifests

### Refer for codebase -> bloodcamp.php(Jenkinsfile-EKs) Repo
##### NOTE: There should be key_name = nasa in your us-east-1 region

### Important points
##### 1.) After the demo completed delete all the terraform resources
##### 2.) Delete ArgoCD/Ingress controller which has LB atatched to it.
##### 3.) Also, delete the pvc so that EBS gets deleted
##### 4.) Finally remove remaining resources with terraform
## These can cause credits exhuastion
