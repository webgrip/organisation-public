variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster."
  type        = string
}

variable "node_group_role_arn" {
  description = "ARN of the IAM role for the node group."
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.31"
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

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes."
  type        = number
  default     = 50
}

variable "environment" {
  description = "Deployment environment (e.g., staging, production)."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}

variable "endpoint_private_access" {
  description = "Whether the EKS cluster's API server endpoint is private."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS cluster's API server endpoint is public."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks to allow access to the public endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of cluster log types to enable."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

