
terraform {
  backend "s3" {
    bucket         = "devsecops-156041402173-us-east-1"
    key            = "tfstate/devsecops-project.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}