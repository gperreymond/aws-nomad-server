resource "aws_vpc_security_group_egress_rule" "nomad_egress" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "internal_nomad_ingress_services_80" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "internal_nomad_ingress_services_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 20000
  ip_protocol       = "tcp"
  to_port           = 32000
}

resource "aws_vpc_security_group_ingress_rule" "internal_nomad_ingress_services_udp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 20000
  ip_protocol       = "udp"
  to_port           = 32000
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


resource "aws_vpc_security_group_ingress_rule" "internal_etcd_ingress_2379_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 2379
  ip_protocol       = "tcp"
  to_port           = 2379
}

resource "aws_vpc_security_group_ingress_rule" "internal_etcd_ingress_2380_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 2380
  ip_protocol       = "tcp"
  to_port           = 2380
}

resource "aws_vpc_security_group_ingress_rule" "internal_vxlan_ingress_4789_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 4789
  ip_protocol       = "tcp"
  to_port           = 4789
}

resource "aws_vpc_security_group_ingress_rule" "internal_vxlan_ingress_4789_udp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = local.vpc_cidr
  from_port         = 4789
  ip_protocol       = "udp"
  to_port           = 4789
}

resource "null_resource" "security_group_rules" {
  depends_on = [
    aws_vpc_security_group_egress_rule.nomad_egress,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4646_tcp,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4647_tcp,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4648_tcp,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4648_udp,
    aws_vpc_security_group_ingress_rule.internal_etcd_ingress_2379_tcp,
    aws_vpc_security_group_ingress_rule.internal_etcd_ingress_2380_tcp,
    aws_vpc_security_group_ingress_rule.internal_vxlan_ingress_4789_tcp,
    aws_vpc_security_group_ingress_rule.internal_vxlan_ingress_4789_udp
  ]
}