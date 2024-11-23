variable "environment" {
  default = "staging"
}

variable "region" {
  default = "eu-west-1"
}

variable "cluster_name" {
  default = "staging-eks-cluster"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "desired_capacity" {
  default = 2
}

variable "min_capacity" {
  default = 1
}

variable "max_capacity" {
  default = 3
}

variable "instance_types" {
  default = ["t3.medium"]
}

variable "tags" {
  default = {
    Environment = "staging"
    Project     = "MyProject"
  }
}
