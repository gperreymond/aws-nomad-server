locals {
  nomad_certificats = jsondecode(data.aws_secretsmanager_secret_version.nomad_certificats.secret_string)
}