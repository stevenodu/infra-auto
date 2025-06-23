# Lookup existing IAM role (same as before)
data "aws_iam_role" "existing_ssm_role" {
  name = "SSMRoleForEC2"
}

locals {
  ssm_role_exists = can(data.aws_iam_role.existing_ssm_role.arn)
}

resource "aws_iam_role" "ssm_role" {
  count = local.ssm_role_exists ? 0 : 1
  name  = "SSMRoleForEC2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

locals {
  ssm_role_name = local.ssm_role_exists ? data.aws_iam_role.existing_ssm_role.name : aws_iam_role.ssm_role[0].name
}

resource "aws_iam_role_policy_attachment" "ssm_role_attach" {
  role       = local.ssm_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Lookup existing instance profile
data "aws_iam_instance_profile" "existing_profile" {
  name = "SSMProfile"
}

locals {
  ssm_profile_exists = can(data.aws_iam_instance_profile.existing_profile.arn)
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMProfile-${terraform.workspace}"
  role = local.ssm_role_name
}

# ✅ Corrected reference — no indexing
locals {
  ssm_profile_name = local.ssm_profile_exists ? data.aws_iam_instance_profile.existing_profile.name : aws_iam_instance_profile.ssm_profile.name
}
