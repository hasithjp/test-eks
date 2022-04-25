module "bastion" {
  source                = "Guimove/bastion/aws"
  bucket_name           = "bastion-logs-bucket"
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  is_lb_private         = "false"
  bastion_host_key_pair = "bastion_key"
  create_dns_record     = "false"
  instance_type         = "t2.medium"
  bastion_instance_count     = 1
  bastion_iam_role_name      = "bastion-iam-role"
  elb_subnets                = module.vpc.public_subnets
  auto_scaling_group_subnets = module.vpc.public_subnets
  bastion_security_group_id  = aws_security_group.bastion_sg.id
}
