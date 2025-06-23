# Lookup existing IAM role (same as before)
data "aws_iam_role" "existing_ssm_role" {
  name = "SSMRoleForEC2"
}

# Check if the role exists
locals {
  ssm_role_exists = can(data.aws_iam_role.existing_ssm_role.arn)
}

# Create role if not found
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

# Use dynamic role name
locals {
  ssm_role_name = local.ssm_role_exists ? data.aws_iam_role.existing_ssm_role.name : aws_iam_role.ssm_role[0].name
}

# Attach policy
resource "aws_iam_role_policy_attachment" "ssm_role_attach" {
  role       = local.ssm_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Lookup existing instance profile (safe fail)
data "aws_iam_instance_profile" "existing_profile" {
  name = "SSMProfile"
}

# Check if it already exists
locals {
  ssm_profile_exists = can(data.aws_iam_instance_profile.existing_profile.arn)
}

# Conditionally create profile
resource "aws_iam_instance_profile" "ssm_profile" {
  count = local.ssm_profile_exists ? 0 : 1
  name  = "SSMProfile"
  role  = local.ssm_role_name
}

# Use dynamic instance profile name
locals {
  ssm_profile_name = local.ssm_profile_exists ? data.aws_iam_instance_profile.existing_profile.name : aws_iam_instance_profile.ssm_profile[0].name
}
