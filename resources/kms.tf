module "common_aws_kms_key" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-kms-wrapper?ref=v1.0.8"
  name                    = [format("%s-kms-common-key-%s-%s", var.company_prefix, local.region_prefix, var.env)]
  description             = "Encryption Decryption Key"
  rotation_period_in_days = 90
  multi_region            = false
  key_statements          = local.key_statements
  tags                    = local.tags
}
