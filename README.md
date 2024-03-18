# AWS NOMAD SERVER

## Documentations

### Nomad

> Network  
* https://www.hashicorp.com/resources/running-cilium-with-nomad
* https://cosmonic.com/blog/engineering/netreap-a-practical-guide-to-running-cilium-in-nomad
* https://github.com/cosmonic-labs/netreap
* https://medium.com/be-tech-with-santander/using-docker-overlay-networks-configuration-guide-526b469befa4
* https://docker-k8s-lab.readthedocs.io/en/latest/docker/docker-flannel.html
* https://github.com/flannel-io/flannel/blob/master/Documentation/running.md
* https://www.linkedin.com/pulse/docker-networking-unleashing-power-overlay-networks-abdelrazek-1gmhf
* https://medium.com/@nobelrakib03/multi-container-host-networking-using-vxlan-overlay-network-c2ae7dc75c2c

> Common 
* https://developer.hashicorp.com/nomad/tutorials/transport-security/security-enable-tls
* https://developer.hashicorp.com/nomad/tutorials/manage-clusters/outage-recovery

### Terraform

* https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
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
# how to generate certificats?
$ ./nomad-generate-certificats.sh -aws_region eu-west-1 -nomad_region europe -nomad_datacenter infra
# how to use the module with terragrunt?
$ terragrunt "[plan|apply|destroy|etc...]" --terragrunt-config examples/stages/europe-infra.hcl
# how to upgrade or provisionning nomad servers from inside?
$ ./nomad-upgrade.sh -stage examples/stages/europe-infra.hcl
# how to bootstrap nomad servers?
$ ./nomad-bootstrap.sh -stage examples/stages/europe-infra.hcl
```
