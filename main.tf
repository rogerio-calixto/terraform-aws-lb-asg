
provider "aws" {
  region  = var.region
  profile = local.aws_profile
}

module "network" {
  source        = "./modules/network"
  project       = local.project
  subnet_counts = var.subnet_counts
}