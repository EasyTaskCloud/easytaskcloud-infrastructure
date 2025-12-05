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

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
  name = "easytaskcloud-igw"
}

module "routing" {
  source = "./modules/routing"

  vpc_id            = module.vpc.vpc_id
  igw_id            = module.igw.igw_id

  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
}

module "security_groups" {
  source = "./modules/security groups"

  vpc_id        = module.vpc.vpc_id
  my_ip         = "95.91.213.239/32"   # 🔁 DEINE IP eintragen
  project_name = "easytaskcloud sg"
}

module "alb" {
  source = "./modules/Alb"

  project_name   = "easytaskcloud"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.subnets.public_subnet_ids
  web_sg_id      = module.security_groups.web_sg_id
}

module "ec2_docker" {
  source = "./modules/ec2-docker"

  project_name        = "easytaskcloud"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  web_sg_id           = module.security_groups.web_sg_id
  app_sg_id           = module.security_groups.app_sg_id
  alb_target_group_arn = module.alb.target_group_arn
}

module "rds" {
  source = "./modules/rds"

  project_name       = "easytaskcloud"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.subnets.private_subnet_ids
  app_sg_id          = module.security_groups.app_sg_id
  db_sg_id           = module.security_groups.db_sg_id
}