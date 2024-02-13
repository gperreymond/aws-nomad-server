resource "random_id" "gossip_encryption_key" {
  byte_length = 32
}

resource "aws_secretsmanager_secret" "configs" {
  name                    = "nomad-server-${local.nomad.datacenter}-configs"
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
  name                    = "nomad-server-${local.nomad.datacenter}-envs"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "envs" {
  secret_id = aws_secretsmanager_secret.envs.id
  secret_string = jsonencode(
    merge({
      APP_NOMAD_VERSION = local.nomad.version
      }, local.consul.enabled == true ? {
      APP_CONSUL_VERSION = local.consul.version
      } : {}
    )
  )
}
