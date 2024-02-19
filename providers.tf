provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge(var.aws_default_tags, {
      NomadRegion     = local.nomad.region
      NomadDatacenter = local.nomad.datacenter
      NomadType       = "server"
    })
  }
}
