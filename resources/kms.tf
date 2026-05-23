# KMS Key for DynamoDB encryption

module "common_aws_kms_key" {
  source                  = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-kms-wrapper?ref=v1.0.0"
  name                    = [format("%s-kms-dynamodb-key-%s-%s", var.company_prefix, local.region_prefix, var.env)]
  description             = "KMS key for DynamoDB table encryption"
  rotation_period_in_days = 90
  multi_region            = false
  key_statements          = []
  tags                    = local.tags
}
