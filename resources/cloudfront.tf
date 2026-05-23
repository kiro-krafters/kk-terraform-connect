module "cloudfront" {
  count  = var.is_primary ? 1 : 0
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-cloudfront-wrapper?ref=v1.0.8"

  aliases                = []
  enabled                = var.enabled
  comment                = var.comment
  http_version           = "http2"
  wait_for_deployment    = true
  retain_on_delete       = false
  price_class            = null
  default_root_object    = var.default_root_object
  is_ipv6_enabled        = var.is_ipv6_enabled
  restrictions           = local.restrictions
  origin_access_control  = local.origin_access_control
  origin                 = local.origin
  custom_error_response  = local.custom_error_response
  default_cache_behavior = local.default_cache_behavior
  ordered_cache_behavior = local.ordered_cache_behavior
  tags                   = merge(local.tags, { name = "${var.company_prefix}-cloudfront-sms-sender-${var.env}" })
}

module "case_management_cloudfront" {
  count  = var.is_primary ? 1 : 0
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-cloudfront-wrapper?ref=v1.0.8"

  aliases                = []
  enabled                = var.enabled
  comment                = var.comment
  http_version           = "http2"
  wait_for_deployment    = true
  retain_on_delete       = false
  price_class            = null
  default_root_object    = var.default_root_object
  is_ipv6_enabled        = var.is_ipv6_enabled
  restrictions           = local.restrictions
  origin_access_control  = local.origin_access_control_cm
  origin                 = local.origin_cm
  custom_error_response  = local.custom_error_response
  default_cache_behavior = local.default_cache_behavior_cm
  ordered_cache_behavior = local.ordered_cache_behavior_cm
  cloudfront_functions   = local.cloudfront_functions_cm
  tags                   = merge(local.tags, { name = "${var.company_prefix}-cloudfront-case-management-${var.env}" })
}
