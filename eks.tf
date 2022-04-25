# Provisioning EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # EKS Worker nodes configs
  worker_groups = [
    {
      name                          = "eks-workers"
      instance_type                 = "m4.2xlarge"
      additional_security_group_ids = [aws_security_group.private_sg.id]
      asg_desired_capacity          = 1
      asg_max_size                  = 3
    }
  ]
}
