data "aws_availability_zones" "available" {}

data "aws_route53_zone" "this" {
  zone_id = var.aws_zone_id
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

data "jinja_template" "nomad_config_hcl" {
  template = "${path.module}/configs/nomad.j2"
  context {
    type = "yaml"
    data = <<-EOF
region: "${local.nomad.region}"
datacenter: "${local.nomad.datacenter}"
bootstrap_expect: "${local.nomad.bootstrap_expect}"
encrypt: "${random_id.gossip_encryption_key.b64_std}"
EOF
  }
}

data "jinja_template" "consul_config_hcl" {
  template = "${path.module}/configs/consul.j2"
  context {
    type = "yaml"
    data = <<-EOF
datacenter: "${local.consul.datacenter}"
EOF
  }
}
