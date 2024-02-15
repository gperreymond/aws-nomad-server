module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  create_vpc = var.aws_create_vpc

  name                         = local.nomad.datacenter
  azs                          = slice(data.aws_availability_zones.available.names, 0, 3)
  enable_ipv6                  = true
  public_subnet_ipv6_native    = true
  public_subnet_ipv6_prefixes  = [0, 1, 2]
  private_subnet_ipv6_native   = true
  private_subnet_ipv6_prefixes = [3, 4, 5]
  enable_nat_gateway           = false
  create_egress_only_igw       = true
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.3.1"

  create = true

  name                        = local.nomad.datacenter
  min_size                    = 3
  max_size                    = 9
  ebs_optimized               = true
  enable_monitoring           = true
  image_id                    = data.aws_ami.latest_ubuntu.id
  instance_type               = "m5a.large"
  vpc_zone_identifier         = module.vpc.private_subnets
  create_iam_instance_profile = false
  iam_role_name               = "nomad-server-${local.nomad.datacenter}"
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

resource "random_string" "ssm_bucket_suffix" {
  length  = 32
  special = false
}

module "ssm_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  create_bucket = true

  bucket        = "nomad-server-${local.nomad.datacenter}-${random_string.ssm_bucket_suffix.result}"
  acl           = "private"
  force_destroy = true
}