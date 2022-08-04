#!/usr/bin/env python3
"""
Build the Terraform deployment configuration files using environment variable values.
"""
import os
import glob
import json
import boto3
import argparse

infra_root = os.path.abspath(os.path.dirname(__file__))


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("component")
#parser.add_argument("project")
args = parser.parse_args()


terraform_variable_template = """
variable "{name}" {{
  default = "{val}"
}}
"""

terraform_state_template = """
module "dev-tfstate" {{
  source         = "../modules/terraform-state-s3"
  env            = "{stage}"
  s3_bucket      = "{bucket}"
  s3_bucket_name = "{project} Terraform State Store"
  dynamodb_table = "ps_terraform_{project}"
  client         = "{client}"
  project        = "{project}"
}}
"""
# terraform_backend_template = """# Auto-generated during infra build process.
# # Please edit infra/build_deploy_config.py directly.
# terraform {{
#   backend "s3" {{
#     bucket = "{bucket}"
#     dynamodb_table = "ps_terraform_{project}"
#     encrypt = "true"
#     key = "{project}/myprojectname-{stage}.tfstate"
#     region = "{region}"
#     {profile_setting}
#   }}
# }}
# """

terraform_providers_template = """# Auto-generated during infra build process.
# Please edit infra/build_deploy_config.py directly.
provider aws {{
  region                  = "{aws_region}"
  shared_credentials_file = "~/.aws/credentials"
  {profile_setting}
}}

"""

env_vars_to_infra = [
    "AWS_DEFAULT_REGION",
    "PROJECT_PROFILE",
    "PROJECT_DEPLOYMENT_STAGE",
    "PROJECT_INFRA_TAG_PROJECT",
    "PROJECT_INFRA_TAG_CLIENT"
]

# with open(os.path.join(infra_root, args.component, "backend.tf"), "w") as fp:
#     caller_info = boto3.client("sts").get_caller_identity()
#     if os.environ.get('AWS_PROFILE'):
#         profile = os.environ['AWS_PROFILE']
#         profile_setting = f'profile = "{profile}"'
#     else:
#         profile_setting = ''
#     #print(profile)
#     fp.write(terraform_backend_template.format(
#         bucket=os.environ['PROJECT_S3_BUCKET'].format(
#             account_id=caller_info['Account']),
#         comp=args.component,
#         stage=os.environ['PROJECT_DEPLOYMENT_STAGE'],
#         project=os.environ['PROJECT_INFRA_TAG_PROJECT'],
#         region=os.environ['AWS_DEFAULT_REGION'],
#         dynamodb_table=os.environ['PROJECT_DYNAMODB_TABLE'],
#         profile_setting=profile_setting,
#     ))

with open(os.path.join(infra_root, args.component, "variables.tf"), "w") as fp:
    fp.write("# Auto-generated during infra build process." + os.linesep)
    fp.write("# Please edit infra/build_deploy_config.py directly." + os.linesep)
    for key in env_vars_to_infra:
        val = os.environ[key]
        fp.write(terraform_variable_template.format(name=key, val=val))

with open(os.path.join(infra_root, args.component, "main.tf"), "w") as fp:
    caller_info = boto3.client("sts").get_caller_identity()
    if os.environ.get('AWS_PROFILE'):
        profile = os.environ['AWS_PROFILE']
        profile_setting = f'profile = "{profile}"'
    else:
        profile_setting = ''    
    fp.write(terraform_state_template.format(
        bucket=os.environ['PROJECT_S3_BUCKET'].format(account_id=caller_info['Account']),
        aws_region=os.environ['AWS_DEFAULT_REGION'],
        stage=os.environ['PROJECT_DEPLOYMENT_STAGE'],
        project=os.environ['PROJECT_INFRA_TAG_PROJECT'],
        client=os.environ['PROJECT_INFRA_TAG_CLIENT'],
        profile_setting=profile_setting,
    ))

with open(os.path.join(infra_root, args.component, "providers.tf"), "w") as fp:
    fp.write(terraform_providers_template.format(
        aws_region=os.environ['AWS_DEFAULT_REGION'],
        profile_setting=profile_setting,
    ))    
