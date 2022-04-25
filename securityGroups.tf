# Security Groups
locals {
  ports_in  = [443, 80]
}

# Security Group for public subnet resources
resource "aws_security_group" "public_sg" {
  name_prefix = "public_sg"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Security Group for private subnet resources
resource "aws_security_group" "private_sg" {
  name_prefix = "private_sg"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = module.vpc.public_subnets
    }
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [module.bastion.elb_ip]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

# Security Group for bastion host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "bastion_sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = var.allowed_bastion_ip_block
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
