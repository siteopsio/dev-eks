# Development AWS EKS (QA/UAT)
## EKS

Taken from https://learn.hashicorp.com/tutorials/terraform/eks?in=terraform/kubernetes

Run terraform

```
terraform init
terraform plan
terraform apply
```

* TODO: Fill in the documentation.
* TODO: create SC (storage class) with faster (gp3) * storage (EFS?)
* TODO: flesh out pod specs (storage etc)
* TODO: create containers with app and store in ECS
* TODO: Add Dockerfile to react and magento repos to create app containers

Run the following command to retrieve the access credentials for your cluster and automatically configure kubectl
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
----
### This is for the learning example and overly complicated. Ignore this section


Deploy Kubernetes Metrics Server
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

```
kubectl get deployment metrics-server -n kube-system
```
Deploy Kubernetes Dashboard
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
```

Run the local kubectl proxy for the cluster (open in another terminal window)
```
kubectl proxy
```

Open the dashboard
```
open http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

Create the role binding resource to authenticate to the dashboard
```
kubectl apply -f https://raw.githubusercontent.com/hashicorp/learn-terraform-provision-eks-cluster/master/kubernetes-dashboard-admin.rbac.yaml
```

Generate the authorization token.
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')
```

Select "Token" on the Dashboard UI then copy and paste the entire token you receive into the dashboard authentication screen to sign in. You are now signed in to the dashboard for your Kubernetes cluster.

---

# Learn Terraform - Provision an EKS Cluster

This code inspired by the repo to the [Provision an EKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster), containing
Terraform configuration files to provision an EKS cluster on AWS.

### Get the latest terraform

* On Mac use the [tfswitch](https://github.com/warrensbox/terraform-switcher) if not installed
* Simply type tfswitch and select the version to use

        ➜ tfswitch
        ? Select Terraform version: 
        ▸ 0.13.3 *recent
            0.12.24 *recent
            0.12.21 *recent
            0.13.2
        ↓   0.13.1
* Or select manually

        ➜ tfswitch 0.11.14
        Switched terraform to version "0.11.14" 

        ➜ tfswitch 0.13.3 
        Switched terraform to version "0.13.3" 

### Authentication to AWS/Okta
- A valid authentication to AWS/Okta is required. If you have gimme-aws-creds or ps-connect installed and configured just login using:

        gimme-aws-creds --profile myprojectname && awsp myprojectname

### Initial config for new projects

* create a new branch naming it clientname-projectname
* Edit the Makefile.env and change the variables.
* run "make python" to install the python code dependencies
* initialize the s3 state store

        make python
        make stateinit
        make stateplan
        make stateapply



### Locked states
If the state becomes locked due to a failed or terminated run force an unlock

```
[dev@local-myprojectname puppetmaster]$ terraform plan
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: ConditionalCheckFailedException: The conditional request failed
        status code: 400, request id: S43AUKRS030MKRU71RB951OFKRVV4KQNSO5AEMVJF66Q9ASUAAJG
Lock Info:
  ID:        9312a042-4963-83e4-ed2a-996f3b999f66
  Path:      com.myprojectname.production.terraform/myprojectname/terraform-puppet.tfstate
  Operation: OperationTypePlan
  Who:       dev@local-myprojectname
  Version:   0.11.7
  Created:   2018-08-07 16:13:25.97538103 +0000 UTC
```
```
 terraform force-unlock 312a042-4963-83e4-ed2a-996f3b999f66
```

## File Layout
```
├── README.md
├── dev-cluster
│   ├── README.md
│   ├── eks-cluster.tf
│   ├── kubernetes-dashboard-admin.rbac.yaml
│   ├── kubernetes.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── security-groups.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── vpc.tf
├── modules
│   └── terraform-state-s3
│       ├── README.md
│       ├── main.tf
│       ├── variables.tf
│       └── versions.tf
└── tfstate
    ├── Makefile
    ├── Makefile.env
    ├── README.md
    └── build_state_config.py
```