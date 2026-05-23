# Required variables for DynamoDB tables

variable "company_prefix" {
  type        = string
  description = "Company prefix for resource naming."
}

variable "company" {
  type        = string
  description = "Company name."
}

variable "project" {
  type        = string
  description = "Project name."
  default     = "KK"
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "env" {
  type        = string
  description = "Deployment environment (dev, stg, prd)."
}

variable "account_number" {
  type        = string
  description = "AWS Account Number."
}

variable "role_name" {
  type        = string
  description = "IAM role name for deployment."
}

variable "is_primary" {
  type        = bool
  description = "Set to true for primary region (us-east-1). DynamoDB tables will only be created in primary region."
  default     = false
}
