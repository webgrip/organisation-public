variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.31"
}

variable "node_group_role_arn" {
  description = "ARN of the IAM role for the node group."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of worker nodes."
  type        = number
}

variable "min_capacity" {
  description = "Minimum number of worker nodes."
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of worker nodes."
  type        = number
}

variable "instance_types" {
  description = "List of EC2 instance types for worker nodes."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default = ["203.0.113.0/24"]
}
