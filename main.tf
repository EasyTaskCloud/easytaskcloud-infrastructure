provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "easytaskcloud-vpc"
}

module "subnets" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  public_subnets = {
    "eu-north-1a" = "10.0.1.0/24"
    "eu-north-1b" = "10.0.2.0/24"
  }

  private_subnets = {
    "eu-north-1a" = "10.0.11.0/24"
    "eu-north-1b" = "10.0.12.0/24"
  }
}
