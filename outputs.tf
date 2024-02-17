output "aws_region" {
  value = var.aws_region
}

output "ssm_document_name" {
  value = aws_ssm_document.this.name
}

output "nomad_datacenter" {
  value = local.nomad.datacenter
}