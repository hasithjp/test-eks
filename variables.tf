variable "region" {
  description = "Region"
  default     = "us-east-1"
}

variable "cluster_name"{
  description = "EKS Cluster Name"
  default = "ls-eks-test-cluster"
}

variable "allowed_bastion_ip_block"{
  description = "Allowed IP Block to Bastion Host"
  type        = list(string)
}
