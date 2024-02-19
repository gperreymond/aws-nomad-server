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
  value = "https://${aws_route53_record.external.name}"
}