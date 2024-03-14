locals {
  tfvars = {
    aws_region   = "eu-west-1"
    aws_zone_id  = "Z04556983LHLUI6UUOJ30"
    aws_vpc_cidr = "10.100.0.0/16"
    aws_default_tags = {
      ManagedBy = "Terraform"
    }
    nomad_version    = "1.7.6"
    nomad_region     = "europe"
    nomad_datacenter = "infra"
  }
}

terraform {
  source = ".//"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket  = "subaccounts-terraform-states"
    key     = "europe-infra/aws-nomad-servers.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}

inputs = local.tfvars
