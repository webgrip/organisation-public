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

  cluster_name            = var.cluster_name
  cluster_role_arn        = module.iam.eks_cluster_role_arn
  node_group_role_arn     = module.iam.eks_node_group_role_arn
  private_subnets         = module.vpc.private_subnets
  kubernetes_version      = var.kubernetes_version
  desired_capacity        = var.desired_capacity
  min_capacity            = var.min_capacity
  max_capacity            = var.max_capacity
  instance_types          = var.instance_types
  node_disk_size          = var.node_disk_size
  environment             = var.environment
  tags                    = var.tags
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access
  public_access_cidrs     = var.public_access_cidrs
}
