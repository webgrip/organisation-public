terraform {
  backend "s3" {
    bucket         = "webgrip-terraform-state-0002"   # Replace with the bucket name from bootstrap output
    key            = "${var.environment}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "webgrip-terraform-lock-0002"  # Replace with the table name from bootstrap output
    encrypt        = true
  }
}
