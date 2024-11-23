variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes."
  type        = number
  default     = 50
}
