terraform {
  backend "s3" {
    bucket         = "stcok-market-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "eu-west-2"   
  }
}
