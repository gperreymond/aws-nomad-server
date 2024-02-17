variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
  type    = any
  default = {}
}

variable "aws_create_vpc" {
  type    = bool
  default = true
}

variable "aws_vpc_cidr" {
  type        = string
  description = "If create_vpc is true, then the vpc will use this cidr."
  default     = "10.100.0.0/16"
}

variable "aws_vpc_id" {
  type        = string
  description = "If create_vpc is false, then the vpc will not be created, and the one behind the id will be used."
  default     = ""
}

variable "aws_instance_type" {
  type    = string
  default = "m5a.large"
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
