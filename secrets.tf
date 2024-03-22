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
    {
      nomad_config_hcl = data.jinja_template.nomad_config_hcl.result
    }
  )
}

resource "aws_secretsmanager_secret" "envs" {
  name                    = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-envs"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "envs" {
  secret_id = aws_secretsmanager_secret.envs.id
  secret_string = jsonencode(
    {
      NOMAD_VERSION       = local.nomad.version
      CNI_PLUGINS_VERSION = var.cni_plugins_version
      NOMAD_REGION        = local.nomad.region
      NOMAD_DATACENTER    = local.nomad.datacenter
    }
  )
}

resource "aws_secretsmanager_secret" "etcd" {
  name                    = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-etcd"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "etcd" {
  secret_id = aws_secretsmanager_secret.etcd.id
  secret_string = jsonencode(
    { for idx, instance in module.nomad_servers : instance.id => {
      NODE_NAME         = "etcd-node-${idx}"
      NODE_IP           = instance.private_ip
      INITIAL_CLUSTER   = join(",", [for idx, instance in module.nomad_servers : "etcd-node-${idx}=http://${instance.private_ip}:2380"])
      CLUSTER_ENDPOINTS = join(",", [for idx, instance in module.nomad_servers : "http://${instance.private_ip}:2380"])
    } }
  )
}