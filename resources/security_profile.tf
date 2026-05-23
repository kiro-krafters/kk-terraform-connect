module "security_profile_stack" {
  count        = var.is_primary ? 1 : 0
  source       = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-cloudformation-wrapper?ref=v1.0.0"
  name         = "${var.company_prefix}-security-profiles"
  template_url = "https://${var.company_prefix}-s3-cfn-stack-templates-${local.region_prefix}-${var.env}.s3.${var.region}.amazonaws.com/${local.region_prefix}/security-profiles/cb-security-profiles-${local.file_hash_map["cb_security_profiles.yaml"]}.yaml"
  parameters = {
    pConnectInstanceArn = "arn:aws:connect:${var.region}:${var.account_number}:instance/${local.connect_instance_id}"
    pCompanyPrefix      = var.company_prefix
    pEnvironment        = var.env
  }
  depends_on = [module.s3_cfn_objects]
}
