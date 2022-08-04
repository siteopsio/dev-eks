# ------------------------------------------------------------------------------
# main.tf
# ------------------------------------------------------------------------------


provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "myprojectname"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "myprojectname-eks-${random_string.suffix.result}"
  project_name = "myprojectname"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}