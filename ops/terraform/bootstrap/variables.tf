variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "aws_access_key" {
  description = "AWS Access Key ID."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key."
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state."
  type        = string
  default     = "webgrip-terraform-state-0002"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking."
  type        = string
  default     = "webgrip-terraform-lock-0002"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
