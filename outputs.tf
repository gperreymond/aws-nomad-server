output "nomad" {
  value = local.nomad
}

output "consul" {
  value = local.consul
}

output "nomad_config_hcl" {
  value = data.jinja_template.nomad_config_hcl.result
}

output "consul_config_hcl" {
  value = data.jinja_template.consul_config_hcl.result
}