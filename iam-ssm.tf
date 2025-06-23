# Try to read existing IAM role (will fail at plan time if it doesn't exist)
data "aws_iam_role" "existing_ssm_role" {
  name = "SSMRoleForEC2"
}

# Use try() to safely access the data source (avoid plan-time crash)
locals {
  ssm_role_exists = can(data.aws_iam_role.existing_ssm_role.arn)
}

# Create IAM role only if it does not exist
resource "aws_iam_role" "ssm_role" {
  count = local.ssm_role_exists ? 0 : 1
  name  = "SSMRoleForEC2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Choose the correct role name depending on whether it exists
locals {
  ssm_role_name = local.ssm_role_exists ? data.aws_iam_role.existing_ssm_role.name : aws_iam_role.ssm_role[0].name
}

resource "aws_iam_role_policy_attachment" "ssm_role_attach" {
  role       = local.ssm_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMProfile"
  role = local.ssm_role_name
}
