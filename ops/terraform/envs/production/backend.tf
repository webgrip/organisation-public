terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "${terraform.workspace}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
