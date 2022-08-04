# ------------------------------------------------------------------------------
# k8s Cluster
# ------------------------------------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  tags = {
    Environment = "development"
    Name        = "myprojectname"
    Project     = "myprojectname"
    Client      = "myprojectname"
  }


  # TODO: Look at the difference with the worker_groups and worker_groups_launch_template
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#what-is-the-difference-between-node_groups-and-worker_groups
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/spot-instances.md
  # Also allows for use of SPOT instances. 

  # Worker groups (self_managed) - (using Launch Configurations)

  workers_group_defaults = {
    root_volume_type = "gp3"
  }

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

  worker_groups = [
    {
      name          = "worker-group-1"
      instance_type = "t3a.small"
      disk_size     = 30

      additional_userdata           = <<-EOT
                      yum install -y amazon-ssm-agent ec2-instance-connect \
                      systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent 
                                        EOT
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]

      additional_tags = {
        Environment = "development"
        Name        = "myprojectname"
        Project     = "myprojectname"
        Client      = "myprojectname"
      }
    },
    # {
    #   name                          = "worker-group-2"
    #   instance_type                 = "t3a.medium"
    #   additional_userdata           = "echo foo bar"
    #   additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    #   asg_desired_capacity          = 0
    # },
  ]

  # Worker groups (using Launch Templates)
  # worker_groups_launch_template = [
  #   {
  #     name                    = "spot-1"
  #     override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
  #     spot_instance_pools     = 4
  #     asg_max_size            = 5
  #     asg_desired_capacity    = 5
  #     kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
  #     public_ip               = true
  #   },
  # ]


  ##  Node Groups are managed by AWS (easier upgrades but has to be initiated manually)

  # Managed Node Groups
  node_groups_defaults = {
    ami_type         = "AL2_x86_64"
    disk_size        = 30
    root_volume_type = "gp3"
  }

  # node_groups = {
  #   example = {
  #     desired_capacity       = 2
  #     max_capacity           = 10
  #     min_capacity           = 2
  #     disk_type              = "gp3"
  #     create_launch_template = true
  #     instance_types         = ["t3a.small"]
  #     capacity_type          = "SPOT" # or "ON_DEMAND"
  #     k8s_labels = {
  #       Environment = "development"
  #       Name        = "myprojectname"
  #       Project     = "myprojectname"
  #       Client      = "myprojectname"
  #     }

  #     tags = {
  #       Environment = "development"
  #       Name        = "myprojectname"
  #       Project     = "myprojectname"
  #       Client      = "myprojectname"
  #     }
  #     additional_tags = {
  #       # ExtraTag    = "example"
  #       Environment = "development"
  #       Name        = "myprojectname"
  #       Project     = "myprojectname"
  #       Client      = "myprojectname"
  #     }
  #     # taints = [
  #     #   {
  #     #     key    = "dedicated"
  #     #     value  = "gpuGroup"
  #     #     effect = "NO_SCHEDULE"
  #     #   }
  #     # ]
  #     update_config = {
  #       max_unavailable_percentage = 50 # or set `max_unavailable`
  #     }
  #   }
  # }
}




