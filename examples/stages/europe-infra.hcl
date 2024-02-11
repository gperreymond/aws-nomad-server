locals {
  aws_region                   = "eu-west-1"
  datacenter                   = "europe-infra"
  tls_ca_command_line          = "tls ca create"
  tls_cert_server_command_line = "tls cert create -server -region global"
  tls_cert_client_command_line = "tls cert create -client"
  tls_cert_cli_command_line    = "tls cert create -cli"
}

terraform {
  source = ".//"
  // source = "git::https://github.com/gperreymond/aws-nomad-server.git?ref=main"
  before_hook "before_hook_generate_nomad_certificats" {
    commands = ["apply", "plan"]
    execute = [
      "./generate-nomad-certificats.sh",
      "-aws_region", "${local.aws_region}",
      "-datacenter", "${local.datacenter}",
      "-tls_ca_command_line", "${local.tls_ca_command_line}",
      "-tls_cert_server_command_line", "${local.tls_cert_server_command_line}",
      "-tls_cert_client_command_line", "${local.tls_cert_client_command_line}",
      "-tls_cert_cli_command_line", "${local.tls_cert_cli_command_line}"
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
    bucket  = "metron-hashistack-terraform"
    key     = "europe-infra/aws-nomad-server.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

inputs = {
  aws_region = local.aws_region
  datacenter = local.datacenter
}
