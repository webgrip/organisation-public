variable "environment" {
  default = "production"
}

variable "region" {
  default = "eu-west-1"
}

variable "cluster_name" {
  default = "production-eks-cluster"
}

variable "vpc_cidr_block" {
  default = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.1.101.0/24", "10.1.102.0/24"]
}

variable "desired_capacity" {
  default = 3
}

variable "min_capacity" {
  default = 2
}

variable "max_capacity" {
  default = 5
}

variable "instance_types" {
  default = ["t3.medium"]
}

variable "tags" {
  default = {
    Environment = "production"
    Project     = "MyProject"
  }
}
