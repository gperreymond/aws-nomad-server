output "aws_region" {
  value = var.aws_region
}

output "ssm_document_name" {
  value = aws_ssm_document.this.name
}

output "nomad_datacenter" {
  value = local.nomad.datacenter
}

output "aws_route53_record" {
  value = "https://${aws_route53_record.external.name}"
}