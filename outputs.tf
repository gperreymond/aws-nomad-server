output "nomad" {
  value = local.nomad
}

output "consul" {
  value = local.consul
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}