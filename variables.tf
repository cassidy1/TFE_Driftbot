variable "aws_region" {
  default     = "us-west-2"
}

variable "TFE_TOKEN" {
  description = "Token needed for checking workspaces"
}

variable "TFE_URL" {
  description = "Full TFE URL"
}

variable "TFE_ORG" {
  description = "TFE Organization"
}

variable "check_time" {
  description = "How often should runs happen to check for drift"
  default     = 1
}

