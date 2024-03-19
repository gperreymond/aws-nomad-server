output "aws_region" {
  value = var.aws_region
}

output "ssm_document_name" {
  value = aws_ssm_document.this.name
}

output "nomad_region" {
  value = local.nomad.region
}

output "nomad_datacenter" {
  value = local.nomad.datacenter
}

output "nomad_address" {
  value = "https://${aws_route53_record.nomad.name}"
}

output "nomad_etcd" {
  value = { for idx, instance in module.nomad_servers : instance.id => {
    node_name       = "etcd-node-${idx}"
    node_ip         = instance.private_ip
    initial_cluster = join(",", [for idx, instance in module.nomad_servers : "etcd-node-${idx}=http://${instance.private_ip}:2380"])
  } }
}
