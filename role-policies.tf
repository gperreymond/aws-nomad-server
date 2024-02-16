resource "aws_iam_role_policy" "ec2" {
  name = "nomad-server-${local.nomad.datacenter}-ec2"
  role = module.autoscaling.iam_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "autoscaling" {
  name = "nomad-server-${local.nomad.datacenter}-autoscaling"
  role = module.autoscaling.iam_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_bucket" {
  name = "nomad-server-${local.nomad.datacenter}-ssm-bucket"
  role = module.autoscaling.iam_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Effect = "Allow"
        Resource : "arn:aws:s3:::${module.ssm_bucket.s3_bucket_id}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "secretsmanager" {
  name = "nomad-server-${local.nomad.datacenter}-secretsmanager"
  role = module.autoscaling.iam_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Effect = "Allow"
        Resource : "arn:aws:secretsmanager:*:*:secret:nomad-server-${local.nomad.datacenter}-*"
      }
    ]
  })
}

