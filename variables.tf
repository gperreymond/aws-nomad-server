variable "aws_region" {
  type = string
}

variable "nomad_version" {
  type    = string
  default = "1.7.4"
}

variable "nomad_region" {
  type    = string
  default = "global"
}

variable "nomad_datacenter" {
  type    = string
  default = "dc1"
}

variable "consul_enabled" {
  type    = bool
  default = false
}
variable "consul_version" {
  type    = string
  default = "1.17.2"
}

variable "consul_datacenter" {
  type    = string
  default = "dc1"
}
