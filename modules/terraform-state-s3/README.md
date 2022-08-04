# terraform-state

Terraform module to create the S3/DynamoDB backend to store the Terraform state and lock.
The state created by this tf should be stored in source control.

## Usage

Configure your AWS credentials.

    $ brew install awscli
    $ aws configure

Initialize the AWS provider with your preferred region.

    provider "aws" {
      region  = "us-west-2"
      #version = "~> 0.1"
    }

Add the tfstate store resource.

    module "dev-tfstate" {
      source = "github.com/confluentinc/terraform-state"
      env = "dev"
      s3_bucket = "com.example.dev.terraform"
      s3_bucket_name = "Dev Terraform State Store"
      dynamodb_table = "terraform_dev"
    }

This should be used in a dedicated terraform workspace or environment. The
resulting `terraform.tfstate` should be stored in source control. As long as
you configured AWS credentials as above (not in the provider), then no secrets
will be stored in source control as part of your state.

You can now configure your Terraform environments to use this backend:

    terraform {
      backend "s3" {
        bucket         = "com.example.dev.terraform"
        key            = "terraform.tfstate"
        region         = "us-west-2"
        dynamodb_table = "terraform_dev"
      }
    }

## Usage Context

It helps to know how we setup our Terraform environments using this module.
For each environment, we have both an `<env>` workspace and an `<env>-tfstate`
workspace. The `<env>-tfstate` workspace just contains the module usage shown
above. The `<env>` workspace includes `_config.tf` which uses a Terraform
backend configuration like the one shown above.

    $ tree terraform/
    terraform/
    ├── Makefile
    ├── README.md
    ├── environments
    │   ├── dev
    │   │   ├── _config.tf
    │   │   ├── global.auto.tfvars -> ../../global.tfvars
    │   │   ├── global_variables.tf -> ../../variables.tf
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   ├── dev-tfstate
    │   │   ├── main.tf
    │   │   └── terraform.tfstate
    │   ├── prod
    │   │   ├── _config.tf
    │   │   ├── global.auto.tfvars -> ../../global.tfvars
    │   │   ├── global_variables.tf -> ../../variables.tf
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   ├── prod-tfstate
    │   │   ├── main.tf
    │   │   └── terraform.tfstate
    │   ├── stage
    │   │   ├── _config.tf
    │   │   ├── global.auto.tfvars -> ../../global.tfvars
    │   │   ├── global_variables.tf -> ../../variables.tf
    │   │   ├── main.tf
    │   │   ├── terraform.tfvars
    │   │   └── variables.tf
    │   └── stage-tfstate
    │       ├── main.tf
    │       └── terraform.tfstate
    ├── global.tfvars
    ├── modules
    │   └── custom_module
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    └── variables.tf

(NB: Not using Terraform's notions of workspaces here, just directories.)

There's a few other goodies in this setup like global variables and tfvars.
But that's outside the scope of this module. :)

Happy Terraforming!
