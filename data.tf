data "aws_secretsmanager_secret" "nomad_certificats" {
  name = "nomad-server-${var.datacenter}-certs"
}

data "aws_secretsmanager_secret_version" "nomad_certificats" {
  secret_id = data.aws_secretsmanager_secret.nomad_certificats.id
}