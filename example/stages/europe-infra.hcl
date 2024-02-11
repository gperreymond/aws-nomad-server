terraform {
  source = "git::https://github.com/gperreymond/aws-nomad-server.git?ref=main"
  before_hook "before_hook_terragrunt_linter" {
    commands     = ["apply", "plan"]
    execute      = ["terragrunt", "hclfmt"]
    run_on_error = true
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

