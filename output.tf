output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}


output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "eks_cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "kubectl_public_ip" {
  value = aws_instance.kubectl_machine.public_ip
}

resource "aws_instance" "kubectl_machine" {
  ami           = "ami-071899a54a905868f" # Amazon Linux 2 (us-west-2); update if using another region
  instance_type = "t2.micro"

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.kubectl_sg.id]
  associate_public_ip_address = true
  key_name               = "uthmanakz" # Replace with your EC2 key pair name

  tags = {
    Name = "kubectl-bastion"
  }
}