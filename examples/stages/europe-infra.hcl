locals {
  tfvars = {
    aws_region = "eu-west-1"
    aws_default_tags = {
      ManagedBy = "Terraform"
    }
    nomad_datacenter = "europe-infra"
    nomad_region     = "eu-west-1"
  }
}

terraform {
  source = ".//"
  // source = "git::https://github.com/gperreymond/aws-nomad-server.git?ref=main"
  before_hook "before_hook_generate_nomad_certificats" {
    commands = ["apply", "plan"]
    execute = [
      "./generate-nomad-certificats.sh",
      "-aws_region", "${local.tfvars.aws_region}",
      "-region", "${local.tfvars.nomad_region}",
      "-datacenter", "${local.tfvars.nomad_datacenter}"
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket  = "subaccounts-terraform-states"
    key     = "europe-infra/aws-nomad-server.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}

inputs = local.tfvars
