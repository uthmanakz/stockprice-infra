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