locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr = var.aws_vpc_cidr
  nomad = {
    version    = var.nomad_version
    region     = var.nomad_region
    datacenter = var.nomad_datacenter
  }
  consul = {
    enabled    = var.consul_enabled
    version    = var.consul_version
    datacenter = var.consul_datacenter
  }
  aws_vpc_id = module.vpc.vpc_id
}