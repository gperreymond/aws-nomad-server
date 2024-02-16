resource "aws_vpc_security_group_egress_rule" "nomad_egress" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "internal_nomad_ingress_4646_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 4646
  ip_protocol       = "tcp"
  to_port           = 4646
}

resource "aws_vpc_security_group_ingress_rule" "internal_nomad_ingress_4647_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 4647
  ip_protocol       = "tcp"
  to_port           = 4647
}

resource "aws_vpc_security_group_ingress_rule" "internal_nomad_ingress_4648_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 4648
  ip_protocol       = "tcp"
  to_port           = 4648
}

resource "aws_vpc_security_group_ingress_rule" "internal_nomad_ingress_4648_udp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 4648
  ip_protocol       = "udp"
  to_port           = 4648
}