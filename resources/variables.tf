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

variable "is_primary" {
  type        = bool
  description = "Set to true for primary region (us-east-1). DynamoDB tables will only be created in primary region."
  default     = false
}

# ========================================
# Variables for KK Backend
# ========================================

variable "connect_instance_id" {
  description = "Amazon Connect Instance ID"
  type        = string
  default     = "c32edc77-03b2-4b2b-a034-e8db15ed6bc6"
}

variable "connect_instance_arn" {
  description = "Amazon Connect Instance ARN"
  type        = string
  default     = "arn:aws:connect:us-east-1:572805506593:instance/c32edc77-03b2-4b2b-a034-e8db15ed6bc6"
}

variable "connect_queue_general_id" {
  description = "Amazon Connect General Queue ID"
  type        = string
  default     = "5d07050b-4bd7-49d9-b5ff-b3a34c178a3e"
}

variable "connect_queue_claims_id" {
  description = "Amazon Connect Claims Queue ID"
  type        = string
  default     = "f5e46446-af9f-4312-a2c6-4d341a2658ac"
}

variable "connect_chat_flow_id" {
  description = "Amazon Connect Chat Flow ID"
  type        = string
  default     = "8f44dd44-f05f-4440-bb7b-241f9f0687e4"
}

variable "connect_voice_flow_id" {
  description = "Amazon Connect Voice Flow ID"
  type        = string
  default     = "30b010e4-ace8-442f-a888-7fc45705afc9"
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
  default     = "us-east-1_wu6MlqiRs"
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  type        = string
  default     = "arn:aws:cognito-idp:us-east-1:572805506593:userpool/us-east-1_wu6MlqiRs"
}

variable "lex_bot_id" {
  description = "Amazon Lex Bot ID"
  type        = string
  default     = "JMB1UAAJFA"
}

variable "lex_bot_alias_id" {
  description = "Amazon Lex Bot Alias ID"
  type        = string
  default     = "SLYBZWQN2L"
}

variable "portal_origin" {
  description = "Customer Portal Origin URL"
  type        = string
  default     = "https://d1o9f0v18fkel6.cloudfront.net"
}

variable "ccp_origin" {
  description = "CCP Origin URL"
  type        = string
  default     = "https://d2guk5gxqgnemr.cloudfront.net"
}

variable "admin_origin" {
  description = "Admin Portal Origin URL"
  type        = string
  default     = "https://d3kc2pjxqdt25w.cloudfront.net"
}
