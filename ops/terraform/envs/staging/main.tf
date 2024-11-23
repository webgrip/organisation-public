module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
}

module "eks" {
  source = "../../modules/eks"

  providers = {
    eks = eks
  }

  cluster_name        = var.cluster_name
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_group_role_arn = module.iam.eks_node_group_role_arn
  private_subnets     = module.vpc.private_subnets
  desired_capacity    = var.desired_capacity
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  instance_types      = var.instance_types
  tags                = var.tags
}

module "helm" {
  source = "../../modules/helm"

  providers = {
    helm = helm
  }

  kubeconfig = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_certificate_authority_data
    cluster_name           = module.eks.cluster_name
  }

  release_name     = "my-application"
  chart_repository = "https://charts.example.com"
  chart_name       = "my-app-chart"
  chart_version    = "1.2.3"
  namespace        = "my-app-namespace"
  values           = [file("${path.module}/helm-values/my-app-values.yaml")]
}

# module "monitoring" {
#   source = "../../modules/monitoring"
#   # Module variables
# }
#
# module "logging" {
#   source = "../../modules/logging"
#   # Module variables
# }
