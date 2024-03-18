module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  create_vpc = true

  name               = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  cidr               = local.vpc_cidr
  azs                = local.azs
  enable_nat_gateway = true

  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]

  enable_ipv6                                   = true
  public_subnet_assign_ipv6_address_on_creation = true
  public_subnet_ipv6_prefixes                   = [0, 1, 2]
  private_subnet_ipv6_prefixes                  = [3, 4, 5]
  database_subnet_ipv6_prefixes                 = [6, 7, 8]
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.1"

  create_certificate = true

  domain_name = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}.${data.aws_route53_zone.this.name}"

  zone_id             = var.aws_zone_id
  validation_method   = "DNS"
  wait_for_validation = true
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.8.0"

  create = true

  name                 = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  vpc_id               = local.aws_vpc_id
  subnets              = module.vpc.public_subnets
  preserve_host_header = true
  security_group_ingress_rules = {
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "this" {
  name        = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  port        = 4646
  protocol    = "HTTPS"
  vpc_id      = local.aws_vpc_id
  target_type = "instance"
  health_check {
    path                = "/v1/status/leader"
    port                = 4646
    protocol            = "HTTPS"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = module.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  create = true

  name   = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  vpc_id = local.aws_vpc_id
}

resource "aws_ebs_volume" "nomad_servers" {
  count = local.nomad.bootstrap_expect

  availability_zone = element(local.azs, count.index % 3)
  size              = 50
  encrypted         = true
  type              = "gp3"
}

resource "aws_volume_attachment" "nomad_servers" {
  count = local.nomad.bootstrap_expect

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.nomad_servers[count.index].id
  instance_id = module.nomad_servers[count.index].id
}

module "nomad_servers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  count = local.nomad.bootstrap_expect

  name                        = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  ami                         = data.aws_ami.latest_ubuntu.id
  instance_type               = var.aws_instance_type
  associate_public_ip_address = false
  user_data_replace_on_change = false
  user_data                   = filebase64("${path.module}/configs/cloudconfig.yaml")
  create_iam_instance_profile = false
  iam_instance_profile        = aws_iam_instance_profile.this.name
  vpc_security_group_ids      = [module.security_group.security_group_id]
  monitoring                  = true
  ebs_optimized               = true
  availability_zone           = element(local.azs, count.index % 3)
  subnet_id                   = element(module.vpc.private_subnets, count.index % 3)
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  instance_tags = merge(var.aws_default_tags, {
    NomadRetryJoin  = "${local.nomad.region}-${local.nomad.datacenter}"
    NomadRegion     = local.nomad.region
    NomadDatacenter = local.nomad.datacenter
    NomadType       = "server"
    SSMBucketName   = module.ssm_bucket.s3_bucket_id
    SSMBucketPath   = "scripts/nomad.sh"
  })
  volume_tags = merge(var.aws_default_tags, {
    NomadRegion     = local.nomad.region
    NomadDatacenter = local.nomad.datacenter
    NomadType       = "server"
  })
  tags = merge(var.aws_default_tags, {
    NomadRetryJoin  = "${local.nomad.region}-${local.nomad.datacenter}"
    NomadRegion     = local.nomad.region
    NomadDatacenter = local.nomad.datacenter
    NomadType       = "server"
    SSMBucketName   = module.ssm_bucket.s3_bucket_id
    SSMBucketPath   = "scripts/nomad.sh"
  })

  depends_on = [
    # instance profile
    aws_iam_instance_profile.this,
    # security group 
    # TOTO: null_resource
    aws_vpc_security_group_egress_rule.nomad_egress,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4646_tcp,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4647_tcp,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4648_tcp,
    aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4648_udp
  ]
}

resource "aws_lb_target_group_attachment" "nomad_servers" {
  count = local.nomad.bootstrap_expect

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = module.nomad_servers[count.index].id
  port             = 4646
}

resource "random_string" "ssm_bucket_suffix" {
  length  = 32
  special = false
  upper   = false
}

module "ssm_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  create_bucket = true

  bucket                   = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-${random_string.ssm_bucket_suffix.result}"
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy            = true
}

resource "aws_s3_object" "nomad_script" {
  bucket      = module.ssm_bucket.s3_bucket_id
  key         = "scripts/nomad.sh"
  source      = "${path.module}/configs/nomad.sh"
  source_hash = filemd5("${path.module}/configs/nomad.sh")
}

resource "aws_route53_record" "nomad" {
  zone_id = var.aws_zone_id
  name    = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}.${data.aws_route53_zone.this.name}"
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
