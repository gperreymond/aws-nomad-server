# AWS NOMAD SERVER

## Documentations

* https://developer.hashicorp.com/nomad/tutorials/transport-security/security-enable-tls
* https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest

## How to use asdf

```sh
$ .wtf/install-dependencies.sh
```

## How to use terragrunt

```sh
# linter
$ .wtf/linter.sh
# terragrunt
$ terragrunt "[plan|apply|destroy|etc...]" --terragrunt-config examples/stages/europe-infra.hcl
# how to upgrade or provisionning nomad servers from inside
$ ./nomad-upgrade.sh -stage examples/stages/europe-infra.hcl
```