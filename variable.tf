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
