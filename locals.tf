locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr = var.aws_vpc_cidr
  nomad = {
    version          = var.nomad_version
    region           = var.nomad_region
    datacenter       = var.nomad_datacenter
    bootstrap_expect = var.nomad_bootstrap_expect
  }
  aws_vpc_id = module.vpc.vpc_id
}