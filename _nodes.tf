# module "autoscaling" {
#   source  = "terraform-aws-modules/autoscaling/aws"
#   version = "7.4.1"

#   create = true

#   name                        = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
#   update_default_version      = true
#   min_size                    = local.nomad.bootstrap_expect
#   max_size                    = local.nomad.bootstrap_expect * 3
#   ebs_optimized               = true
#   enable_monitoring           = true
#   image_id                    = "ami-04af9f2b8c2306b1a" // data.aws_ami.latest_ubuntu.id
#   instance_type               = var.aws_instance_type
#   vpc_zone_identifier         = module.vpc.private_subnets
#   create_iam_instance_profile = false
#   iam_instance_profile_arn    = aws_iam_instance_profile.this.arn
#   user_data                   = filebase64("${path.module}/configs/cloudconfig.yaml")
#   metadata_options = {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#     instance_metadata_tags      = "enabled"
#   }
#   security_groups                  = [module.security_group.security_group_id]
#   create_traffic_source_attachment = true
#   traffic_source_identifier        = aws_lb_target_group.this.arn
#   block_device_mappings = [{
#     # Root volume
#     device_name = "/dev/xvda"
#     no_device   = 0
#     ebs = {
#       delete_on_termination = true
#       encrypted             = true
#       volume_size           = 50
#       volume_type           = "gp3"
#     }
#   }]
#   tags = merge(local.default_tags, {
#     NomadRetryJoin  = "${local.nomad.region}-${local.nomad.datacenter}"
#     NomadRegion     = local.nomad.region
#     NomadDatacenter = local.nomad.datacenter
#     NomadType       = "server"
#     SSMBucketName   = module.ssm_bucket.s3_bucket_id
#     SSMBucketPath   = "scripts/nomad.sh"
#   })

#   depends_on = [
#     # instance profile
#     aws_iam_instance_profile.this,
#     # security group
#     aws_vpc_security_group_egress_rule.nomad_egress,
#     aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4646_tcp,
#     aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4647_tcp,
#     aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4648_tcp,
#     aws_vpc_security_group_ingress_rule.internal_nomad_ingress_4648_udp
#   ]
# }