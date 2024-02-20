resource "random_id" "gossip_encryption_key" {
  byte_length = 32
}

resource "aws_secretsmanager_secret" "configs" {
  name                    = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-configs"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "configs" {
  secret_id = aws_secretsmanager_secret.configs.id
  secret_string = jsonencode(
    merge({
      nomad_config_hcl = data.jinja_template.nomad_config_hcl.result
      }, local.consul.enabled == true ? {
      consul_config_hcl = data.jinja_template.consul_config_hcl.result
      } : {}
    )
  )
}

resource "aws_secretsmanager_secret" "envs" {
  name                    = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-envs"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "envs" {
  secret_id = aws_secretsmanager_secret.envs.id
  secret_string = jsonencode(
    merge({
      NOMAD_VERSION       = local.nomad.version
      CNI_PLUGINS_VERSION = var.cni_plugins_version
      NOMAD_REGION        = local.nomad.region
      NOMAD_DATACENTER    = local.nomad.datacenter
      }, local.consul.enabled == true ? {
      CONSUL_VERSION = local.consul.version
      } : {}
    )
  )
}
