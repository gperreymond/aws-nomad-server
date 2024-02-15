resource "aws_iam_role" "autoscaling" {
  name = "nomad-server-${local.nomad.datacenter}"
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
  role       = aws_iam_role.autoscaling.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ec2" {
  name = "test_policy"
  role = aws_iam_role.autoscaling.name
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
  name = "test_policy"
  role = aws_iam_role.autoscaling.name
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
  name = "test_policy"
  role = aws_iam_role.autoscaling.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Effect = "Allow"
        Resource : "arn:aws:s3:::${module.ssm_bucket.s3_bucket_id}-*/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "secretsmanager" {
  name = "test_policy"
  role = aws_iam_role.autoscaling.name
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
        Resource : "arn:aws:secretsmanager:*:*:secret:$nomad-server-${local.nomad.datacenter}-*"
      }
    ]
  })
}

