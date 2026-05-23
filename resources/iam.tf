# ========================================
# IAM Roles and Policies for KK Backend
# ========================================

# Lambda Execution Role
module "kk_backend_lambda_role" {
  source                          = "git::https://github.com/kiro-krafters/kk-terraform-modules.git//terraform-aws-iam/modules/iam-assumable-role?ref=main"
  role_name                       = format("kk-backend-%s-lambdaRole", var.env)
  role_description                = "IAM role for KK Backend Lambda functions"
  create_role                     = true
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.kk_lambda_trust_policy.json
  custom_role_policy_arns = [
    module.kk_backend_lambda_policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  role_path             = "/"
  force_detach_policies = false
  tags                  = local.tags
  depends_on            = [module.kk_backend_lambda_policy]
}

# Lambda Trust Policy
data "aws_iam_policy_document" "kk_lambda_trust_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Lambda Execution Policy
module "kk_backend_lambda_policy" {
  source      = "git::https://github.com/kiro-krafters/kk-terraform-modules.git//terraform-aws-iam/modules/iam-policy?ref=main"
  name        = format("kk-backend-%s-lambda-policy", var.env)
  description = "Policy for KK Backend Lambda functions"
  policy      = data.aws_iam_policy_document.kk_lambda_policy.json
}
