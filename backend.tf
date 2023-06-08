/*terraform {
  backend "s3" {
    bucket  = "punit-terraform-remote-state"
    encrypt = true
    key     = "url-shortener/terraform.tfstate"
    region  = "us-east-1"
    dynamodb_table = "url-shortener-terraform-locks"
  }
}*/

