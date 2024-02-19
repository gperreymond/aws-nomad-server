resource "aws_ssm_document" "this" {
  name          = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "ExecuteScript",
    "mainSteps": [
      {
        "action": "aws:runShellScript",
        "name": "runShellScript",
        "inputs": {
          "runCommand": [
            "bash",
            "/home/ssm-user/upgrade.sh"
          ]
        }
      }
    ]
  }
DOC
}