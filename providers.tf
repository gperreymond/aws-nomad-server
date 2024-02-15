provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge(var.aws_default_tags, {
      NomadDatacenter = local.nomad.datacenter
      NomadType       = "server"
    })
  }
}
