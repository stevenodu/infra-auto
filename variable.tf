variable "aws-integration-token" {
  description = "GitHub Personal Access Token for cloning private repos"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region for deploying resources"
  type        = string
  default     = "eu-west-1"
}


variable "force_redeploy_tag" {
  description = "Dummy tag value used to force EC2 redeployment"
  type        = string
  default     = "initial"
}

variable "rebuild_instance" {
  description = "Change this value to force EC2 recreation"
  type        = bool
  default     = false
}

