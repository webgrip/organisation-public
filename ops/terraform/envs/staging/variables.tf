variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "staging"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "staging-eks-cluster"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.31"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "instance_types" {
  description = "List of EC2 instance types for worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes."
  type        = number
  default     = 50
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "MyProject"
  }
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster's API server endpoint is public."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster's API server endpoint is private."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks to allow access to the public endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
