

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0.0"
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "STOCKPRICE-VPC"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "Project" = "MyEKS"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/stockprice" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/stockprice" = "shared"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "20.37.1" # check latest version if needed

  cluster_name    = "stockprice"
  cluster_version = "1.29"

  subnet_ids = module.vpc.private_subnets  # use private subnets for worker nodes
  vpc_id     = module.vpc.vpc_id


  cluster_endpoint_public_access = false
  cluster_endpoint_private_access        = true
  enable_cluster_creator_admin_permissions = true 
  # cluster_endpoint_public_access_cidrs = ["${aws_instance.kubectl_machine.public_ip}/32"]
  
  cluster_additional_security_group_ids = [aws_security_group.eks_api_sg.id]


  enable_irsa = true

 eks_managed_node_groups = {
  default = {
    min_size      = 3
    desired_size  = 3
    max_size      = 3

    instance_types = ["t3.medium"]
  }
}
}

resource "aws_security_group" "eks_api_sg" {
  name        = "eks-api-sg"
  description = "Allow HTTPS from kubectl EC2"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description              = "Allow HTTPS from kubectl EC2"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    security_groups  = [aws_security_group.kubectl_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


