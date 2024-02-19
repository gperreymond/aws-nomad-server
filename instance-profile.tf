resource "aws_iam_role" "this" {
  name = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ec2" {
  name = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-ec2"
  role = aws_iam_role.this.name
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
  name = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-autoscaling"
  role = aws_iam_role.this.name
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
  name = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-ssm-bucket"
  role = aws_iam_role.this.name
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
  name = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}-secretsmanager"
  role = aws_iam_role.this.name
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
        Resource : "arn:aws:secretsmanager:*:*:secret:nomad-server-${local.nomad.region}-${local.nomad.datacenter}-*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "nomad-server-${local.nomad.region}-${local.nomad.datacenter}"
  role = aws_iam_role.this.name

  depends_on = [
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy.autoscaling,
    aws_iam_role_policy.ec2,
    aws_iam_role_policy.ssm_bucket,
    aws_iam_role_policy.secretsmanager
  ]
}