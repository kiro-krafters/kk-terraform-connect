# Data sources for DynamoDB tables

data "aws_caller_identity" "current" {}

# ========================================
# Data Sources for KK Backend
# ========================================

# S3 Bucket Policy for Serverless Deployment
data "aws_iam_policy_document" "kk_serverless_deployment_bucket_policy" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::kk-backend-serverless-deployment-${local.region_prefix}-${var.env}",
      "arn:aws:s3:::kk-backend-serverless-deployment-${local.region_prefix}-${var.env}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Lambda Execution Policy
data "aws_iam_policy_document" "kk_lambda_policy" {
  # CloudWatch Logs
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:TagResource",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/kk-backend-${var.env}*:*"
    ]
  }

  # Amazon Connect
  statement {
    sid    = "AmazonConnect"
    effect = "Allow"
    actions = [
      "connect:*"
    ]
    resources = [
      var.connect_instance_arn,
      "${var.connect_instance_arn}/*"
    ]
  }

  # Connect Participant
  statement {
    sid    = "ConnectParticipant"
    effect = "Allow"
    actions = [
      "participant:*"
    ]
    resources = ["*"]
  }

  # Amazon Lex
  statement {
    sid    = "AmazonLex"
    effect = "Allow"
    actions = [
      "lex:RecognizeText",
      "lex:RecognizeUtterance",
      "lex:GetSession",
      "lex:PutSession"
    ]
    resources = ["*"]
  }

  # DynamoDB
  statement {
    sid    = "DynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      module.kk_chat_sessions.dynamodb_table_arn,
      "${module.kk_chat_sessions.dynamodb_table_arn}/index/*",
      module.kk_contact_history.dynamodb_table_arn,
      "${module.kk_contact_history.dynamodb_table_arn}/index/*",
      module.kk_callbacks.dynamodb_table_arn,
      "${module.kk_callbacks.dynamodb_table_arn}/index/*",
      module.kk_audit_logs.dynamodb_table_arn,
      "${module.kk_audit_logs.dynamodb_table_arn}/index/*"
    ]
  }

  # Amazon Bedrock
  statement {
    sid    = "AmazonBedrock"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["*"]
  }

  # CloudWatch Metrics
  statement {
    sid    = "CloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData"
    ]
    resources = ["*"]
  }

  # Amazon Cognito
  statement {
    sid    = "AmazonCognito"
    effect = "Allow"
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminDeleteUser",
      "cognito-idp:AdminGetUser",
      "cognito-idp:AdminUpdateUserAttributes",
      "cognito-idp:AdminAddUserToGroup",
      "cognito-idp:AdminRemoveUserFromGroup",
      "cognito-idp:AdminSetUserPassword",
      "cognito-idp:ListUsers",
      "cognito-idp:ListGroups",
      "cognito-idp:ListUsersInGroup"
    ]
    resources = [
      var.cognito_user_pool_arn
    ]
  }

  # KMS
  statement {
    sid    = "KMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      module.common_aws_kms_key.key_arn
    ]
  }
}
