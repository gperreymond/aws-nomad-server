variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type    = any
  default = {}
}

variable "aws_zone_id" {
  type = string
}

variable "aws_vpc_cidr" {
  type = string
}

variable "aws_instance_type" {
  type    = string
  default = "m5a.large"
}

variable "cni_plugins_version" {
  type    = string
  default = "1.4.0"
}

variable "nomad_version" {
  type    = string
  default = "1.7.5"
}

variable "nomad_region" {
  type    = string
  default = "global"
}

variable "nomad_datacenter" {
  type    = string
  default = "dc1"
}

variable "nomad_bootstrap_expect" {
  type    = number
  default = 3
}
