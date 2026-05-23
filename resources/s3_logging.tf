# S3 access logging bucket for all other buckets
module "s3_access_logs_bucket" {
  source                   = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=v1.0.6"
  bucket_name              = format("%s-s3-server-access-logs-%s-%s", var.company_prefix, local.region_prefix, var.env)
  acl                      = null
  object_ownership         = "BucketOwnerEnforced"
  versioning_configuration = { status = false, mfa_delete = false }
  lifecycle_rules          = local.s3_access_logs_lifecycle_rules
  tags                     = local.tags
  attach = {
    access_log_delivery_policy = true
  }
}
