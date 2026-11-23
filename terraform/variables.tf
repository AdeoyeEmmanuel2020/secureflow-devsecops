variable "aws_region" {
  description = "AWS Region used for regional resources. The trail itself is multi-Region."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Lowercase prefix used in resource names."
  type        = string
  default     = "secureflow"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.name_prefix))
    error_message = "name_prefix must be 3-21 lowercase alphanumeric/hyphen characters and begin with a letter."
  }
}

variable "environment" {
  description = "Deployment environment classification."
  type        = string
  default     = "research"

  validation {
    condition     = contains(["research", "development", "test", "staging", "production"], var.environment)
    error_message = "environment must be research, development, test, staging, or production."
  }
}

variable "cloudwatch_retention_days" {
  description = "CloudWatch Logs retention period."
  type        = number
  default     = 365

  validation {
    condition     = contains([30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.cloudwatch_retention_days)
    error_message = "Use an AWS-supported retention value of at least 30 days."
  }
}

variable "noncurrent_version_retention_days" {
  description = "Days to retain noncurrent S3 evidence versions."
  type        = number
  default     = 365

  validation {
    condition     = var.noncurrent_version_retention_days >= 30
    error_message = "Retain noncurrent evidence versions for at least 30 days."
  }
}

variable "kms_deletion_window_days" {
  description = "Waiting period before KMS key deletion."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_days >= 7 && var.kms_deletion_window_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "additional_tags" {
  description = "Additional governance tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
