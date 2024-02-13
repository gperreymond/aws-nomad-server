locals {
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
}