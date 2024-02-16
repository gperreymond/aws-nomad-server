module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  create_vpc = var.aws_create_vpc

  name               = local.nomad.datacenter
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

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  create = true

  name   = local.nomad.datacenter
  vpc_id = module.vpc.vpc_id
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.3.1"

  create = true

  name                        = local.nomad.datacenter
  update_default_version      = true
  min_size                    = 3
  max_size                    = 9
  ebs_optimized               = true
  enable_monitoring           = true
  image_id                    = data.aws_ami.latest_ubuntu.id
  instance_type               = "m5a.large"
  vpc_zone_identifier         = module.vpc.private_subnets
  create_iam_instance_profile = true
  iam_role_name               = "nomad-server-${local.nomad.datacenter}-role"
  iam_role_path               = "/ec2/"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  user_data = filebase64("${path.module}/configs/cloudconfig.yaml")
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  security_groups = [module.security_group.security_group_id]
  tags = {
    SSMBucketName = module.ssm_bucket.s3_bucket_id
    SSMBucketPath = "scripts/nomad.sh"
  }
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

  bucket                   = "nomad-server-${local.nomad.datacenter}-${random_string.ssm_bucket_suffix.result}"
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy            = true
}

resource "aws_s3_object" "nomad_script" {
  bucket = module.ssm_bucket.s3_bucket_id
  key    = "scripts/nomad.sh"
  source = "${path.module}/configs/nomad.sh"
  etag   = filemd5("${path.module}/configs/nomad.sh")
}