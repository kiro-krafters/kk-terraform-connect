# ========================================
# S3 Buckets for KK Backend
# ========================================

# Serverless Deployment Bucket
module "kk_serverless_deployment_bucket" {
  source = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=main"
  
  bucket_name              = format("kk-backend-serverless-deployment-%s-%s", local.region_prefix, var.env)
  acl                      = null
  public_acl_configuration = null
  object_ownership         = "BucketOwnerEnforced"
  
  versioning_configuration = {
    status     = true
    mfa_delete = false
  }

  encryption_configuration = {
    rule = [
      {
        apply_server_side_encryption_by_default = {
          sse_algorithm = "AES256"
        }
        bucket_key_enabled = true
      }
    ]
  }

  tags = local.tags
}

# S3 Bucket Policy for Serverless Deployment
module "kk_serverless_deployment_bucket_policy" {
  source            = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=main"
  create_bucket     = false
  cloudfront_policy = false
  bucket_name       = format("kk-backend-serverless-deployment-%s-%s", local.region_prefix, var.env)
  policy            = data.aws_iam_policy_document.kk_serverless_deployment_bucket_policy.json
  depends_on        = [module.kk_serverless_deployment_bucket]
}
