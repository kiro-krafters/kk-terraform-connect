variable "company_prefix" {
  type        = string
  description = "Company prefix."
}
variable "organization" {
  description = "Organization name in GitHub."
  type        = string
  default     = "CA-Bridge"
}
variable "application" {
  type        = string
  description = "Application name."
  default     = "connect"
}

variable "company" {
  type        = string
  description = "Company name."
}

variable "project" {
  type        = string
  description = "Project name."
  default     = "CCaaS"
}

variable "instance_storage_configs" {
  description = "Map of storage configurations for the Connect instance"
  type        = map(any)
  default     = {}
}
variable "region" {
  type        = string
  description = "AWS region."
}

variable "env" {
  type        = string
  description = "Deployment environment."
}

variable "repo_url" {
  type        = string
  description = "Repository URL."
  default     = "https://github.com/CA-Bridge/ccaas-terraform-connect.git"
}

variable "account_number" {
  description = "Account Number."
  type        = string
  default     = null
}

variable "role_name" {
  description = "Role name."
  type        = string
  default     = "shared-github-oidc-role"
}

variable "create_instance" {
  type        = bool
  description = "Set to true for the first-time deployment to create the instance. Set to false for subsequent deployments to use the existing instance."
  default     = false
}

variable "is_primary" {
  type        = bool
  description = "Set to true for us-east-1. Set to false for us-west-2."
  default     = false
}
variable "cases_domain_id" {
  type        = string
  description = "Cases domain ID (set in terraform.tfvars)"
  default     = null
}
variable "enabled" {
  type        = bool
  description = "Whether the CloudFront distribution is enabled."
  default     = true
}

variable "comment" {
  type        = string
  description = "Comment(discription) for the CloudFront distribution."
  default     = "CloudFront distribution for SMS Sender"
}
variable "default_root_object" {
  type        = string
  description = "Default root object for the CloudFront distribution."
  default     = "index.html"
}
variable "is_ipv6_enabled" {
  type        = bool
  description = "Whether IPv6 is enabled for the CloudFront distribution."
  default     = true
}

variable "outbound_caller_id_number_id" {
  description = "Outbound caller ID number ID."
  type        = string
}

variable "sms_origination_number" {
  description = "SMS origination number."
  type        = string
}
