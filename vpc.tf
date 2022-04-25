# Provisioning VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "eks-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  # One NAT G/W per each AZ as per the given diagram
  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  # Apply network ACLs on Private subnets
  private_dedicated_network_acl = true
  private_inbound_acl_rules     = [
    { "cidr_block": "10.0.4.0/24" , "from_port": 80, "protocol": "tcp", "rule_action": "allow", "rule_number": 100, "to_port": 80 },
    { "cidr_block": "10.0.5.0/24" , "from_port": 80, "protocol": "tcp", "rule_action": "allow", "rule_number": 101, "to_port": 80 },
    { "cidr_block": "10.0.6.0/24" , "from_port": 80, "protocol": "tcp", "rule_action": "allow", "rule_number": 102, "to_port": 80 },
    { "cidr_block": "10.0.4.0/24" , "from_port": 443, "protocol": "tcp", "rule_action": "allow", "rule_number": 103, "to_port": 443 },
    { "cidr_block": "10.0.5.0/24" , "from_port": 443, "protocol": "tcp", "rule_action": "allow", "rule_number": 104, "to_port": 443 },
    { "cidr_block": "10.0.6.0/24" , "from_port": 443, "protocol": "tcp", "rule_action": "allow", "rule_number": 105, "to_port": 443 },
    { "cidr_block": module.bastion.elb_ip , "from_port": 22, "protocol": "tcp", "rule_action": "allow", "rule_number": 106, "to_port": 22 }]
  private_outbound_acl_rules    = [ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 107, "to_port": 65535 } ]

  # Apply network ACLs on Public subnets
  public_dedicated_network_acl = true
  public_inbound_acl_rules     = [
    { "cidr_block": "0.0.0.0/0" , "from_port": 80, "protocol": "tcp", "rule_action": "allow", "rule_number": 100, "to_port": 80 },
    { "cidr_block": "0.0.0.0/0" , "from_port": 443, "protocol": "tcp", "rule_action": "allow", "rule_number": 101, "to_port": 443 },
    { "cidr_block": var.allowed_bastion_ip_block[0] , "from_port": 22, "protocol": "tcp", "rule_action": "allow", "rule_number": 102, "to_port": 22 }]
  public_outbound_acl_rules    = [ { "cidr_block": "0.0.0.0/0", "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 103, "to_port": 65535 } ]

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}
