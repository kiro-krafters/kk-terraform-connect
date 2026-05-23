module "vm_access_secrets" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-secrets-manager-wrapper?ref=v1.0.10"

  items = {
    vm_access_secrets = {
      name                    = format("%s-scrt-vm-access-secrets-%s-%s", var.company_prefix, local.region_prefix, var.env)
      description             = "Stores user credentials for the presigner function"
      recovery_window_in_days = 7
      ignore_secret_changes   = true
      kms_key_id              = module.common_aws_kms_key.key_arn
      secret_string = jsonencode({
        vmx_iam_key_id = module.vm_presigner_user.iam_access_key_id
        vmx_iam_key_secret = module.vm_presigner_user.iam_access_key_secret
      })
      tags = local.tags
    }
  }
}
