# ========================================
# S3 Buckets for KK Backend
# ========================================

# Serverless Deployment Bucket
module "kk_serverless_deployment_bucket" {
  source = "git::https://github.com/kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-s3-bucket-wrapper?ref=main"
  
  bucket_name = format("kk-backend-serverless-deployment-%s-%s", local.region_prefix, var.env)
  
  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = local.tags
}

# S3 Bucket Policy for Serverless Deployment
resource "aws_s3_bucket_policy" "kk_serverless_deployment_policy" {
  bucket = module.kk_serverless_deployment_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          module.kk_serverless_deployment_bucket.s3_bucket_arn,
          "${module.kk_serverless_deployment_bucket.s3_bucket_arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
