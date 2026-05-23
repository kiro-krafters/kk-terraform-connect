# KK Backend Infrastructure

This document describes the Terraform infrastructure for the KK Backend application, which provides serverless backend services for the Kiro Krafters contact center solution.

## Overview

The KK Backend infrastructure consists of:

- **40+ Lambda Functions** for various backend operations
- **4 DynamoDB Tables** for data persistence
- **API Gateway** for REST API endpoints
- **IAM Roles and Policies** for secure access
- **S3 Bucket** for serverless deployment artifacts
- **CloudWatch Log Groups** for monitoring

## Architecture Components

### 1. DynamoDB Tables

#### Chat Sessions Table (`kk_chat_sessions_${env}`)
- **Purpose**: Store active chat session data
- **Hash Key**: `sessionId` (String)
- **Range Key**: `timestamp` (Number)
- **GSI**: CustomerIdIndex (customerId + timestamp)
- **TTL**: Enabled on `expirationTime`
- **Encryption**: KMS encrypted

#### Contact History Table (`kk_contact_history_${env}`)
- **Purpose**: Store historical contact records
- **Hash Key**: `customerId` (String)
- **Range Key**: `contactTimestamp` (Number)
- **GSI**: ContactIdIndex (contactId)
- **Encryption**: KMS encrypted

#### Callbacks Table (`kk_callbacks_${env}`)
- **Purpose**: Manage callback requests
- **Hash Key**: `callbackId` (String)
- **Range Key**: `requestedTime` (Number)
- **GSI**: 
  - CustomerIdIndex (customerId + requestedTime)
  - StatusIndex (status + requestedTime)
- **TTL**: Enabled on `expirationTime`
- **Encryption**: KMS encrypted

#### Audit Logs Table (`kk_audit_logs_${env}`)
- **Purpose**: Track administrative actions
- **Hash Key**: `logId` (String)
- **Range Key**: `timestamp` (Number)
- **GSI**: 
  - AdminUserIdIndex (adminUserId + timestamp)
  - ActionTypeIndex (actionType + timestamp)
- **Encryption**: KMS encrypted

### 2. Lambda Functions

#### Portal Functions
- `health` - Health check endpoint
- `portalChatStart` - Initialize chat session
- `portalChatSendMessage` - Send chat message
- `portalChatGetMessages` - Retrieve chat messages
- `portalChatEnd` - End chat session
- `portalCallbackRequest` - Request callback
- `portalContactSubmit` - Submit contact form

#### AI Functions
- `aiMessage` - Process AI chat messages
- `aiTransfer` - Handle agent transfer
- `aiBedrockMessage` - Bedrock AI integration (29s timeout)

#### Metrics & Monitoring
- `getMetrics` - Retrieve system metrics
- `getBotStats` - Get bot statistics

#### Agent Management
- `getAgents` - List agents
- `updateAgentRoutingProfile` - Update agent routing
- `updateAgentProficiency` - Update agent skills

#### Queue Management
- `getQueues` - List queues
- `updateQueueHours` - Update queue hours

#### Contact Management
- `getContactHistory` - Retrieve contact history
- `triggerCallback` - Trigger callback

#### Admin Functions
- `adminGetCcpConfig` - Get CCP configuration
- `adminListUsers` - List users
- `adminCreateUser` - Create user
- `adminGetUser` - Get user details
- `adminUpdateUser` - Update user
- `adminDeleteUser` - Delete user
- `adminUpdateUserGroup` - Update user group
- `adminListQueues` - List queues (admin)
- `adminCreateQueue` - Create queue
- `adminUpdateQueue` - Update queue
- `adminListRoutingProfiles` - List routing profiles
- `adminCreateRoutingProfile` - Create routing profile
- `adminUpdateRoutingProfile` - Update routing profile
- `adminListSecurityProfiles` - List security profiles
- `adminListContactFlows` - List contact flows
- `adminGetHistoricalAnalytics` - Get historical analytics
- `adminGetContactsAnalytics` - Get contacts analytics
- `adminGetAnalyticsSummary` - Get analytics summary
- `adminGetAuditLogs` - Get audit logs

### 3. IAM Configuration

#### Lambda Execution Role
- **Name**: `kk-backend-${env}-lambdaRole`
- **Permissions**:
  - CloudWatch Logs (create, write)
  - Amazon Connect (full access to instance)
  - Connect Participant API
  - Amazon Lex (recognize, session management)
  - DynamoDB (CRUD operations on all tables)
  - Amazon Bedrock (invoke models)
  - CloudWatch Metrics (read)
  - Amazon Cognito (user management)
  - KMS (encrypt/decrypt)

### 4. API Gateway

- **Type**: REST API (EDGE)
- **Stage**: Environment-based (dev/stg/prd)
- **CORS**: Enabled with wildcard origin
- **Integration**: AWS_PROXY with Lambda functions
- **Authentication**: NONE (handled by application layer)

#### API Endpoints Structure
```
/health (GET)
/portal
  /chat
    /start (POST)
    /{sessionId}
      /message (POST)
      /messages (GET)
      (DELETE)
  /callback (POST)
  /contact (POST)
/ai
  /message (POST)
  /transfer (POST)
  /bedrock
    /message (POST)
/metrics (GET)
/agents (GET)
  /{agentId}
    /routing-profile (PUT)
    /proficiency (PUT)
/queues (GET)
  /{queueId}
    /hours (PUT)
/contacts
  /{customerId} (GET)
/callback (POST)
/bot
  /stats (GET)
/admin
  /ccp-config (GET)
  /users (GET, POST)
    /{userId} (GET, PUT, DELETE)
      /group (PUT)
  /queues (GET, POST)
    /{queueId} (PUT)
  /routing-profiles (GET, POST)
    /{profileId} (PUT)
  /security-profiles (GET)
  /contact-flows (GET)
  /analytics
    /historical (GET)
    /contacts (GET)
    /summary (GET)
  /audit-logs (GET)
```

### 5. S3 Buckets

#### Serverless Deployment Bucket
- **Name**: `kk-backend-serverless-deployment-${region}-${env}`
- **Purpose**: Store Lambda deployment packages
- **Encryption**: AES256
- **Versioning**: Enabled
- **Public Access**: Blocked
- **Policy**: Deny insecure transport

## Environment Variables

All Lambda functions share common environment variables:

```hcl
STAGE                      = var.env
CONNECT_INSTANCE_ID        = var.connect_instance_id
CONNECT_INSTANCE_ARN       = var.connect_instance_arn
CONNECT_QUEUE_GENERAL_ID   = var.connect_queue_general_id
CONNECT_QUEUE_CLAIMS_ID    = var.connect_queue_claims_id
CONNECT_CHAT_FLOW_ID       = var.connect_chat_flow_id
CONNECT_VOICE_FLOW_ID      = var.connect_voice_flow_id
COGNITO_USER_POOL_ID       = var.cognito_user_pool_id
COGNITO_REGION             = var.region
LEX_BOT_ID                 = var.lex_bot_id
LEX_BOT_ALIAS_ID           = var.lex_bot_alias_id
LEX_LOCALE_ID              = "en_US"
BEDROCK_MODEL_ID           = "anthropic.claude-3-haiku-20240307-v1:0"
DYNAMODB_SESSIONS_TABLE    = module.kk_chat_sessions.dynamodb_table_id
DYNAMODB_HISTORY_TABLE     = module.kk_contact_history.dynamodb_table_id
DYNAMODB_CALLBACKS_TABLE   = module.kk_callbacks.dynamodb_table_id
DYNAMODB_AUDIT_TABLE       = module.kk_audit_logs.dynamodb_table_id
PORTAL_ORIGIN              = var.portal_origin
CCP_ORIGIN                 = var.ccp_origin
ADMIN_ORIGIN               = var.admin_origin
```

## Configuration

### Required Variables

Update the following variables in your environment-specific tfvars file:

```hcl
# Amazon Connect
connect_instance_id        = "your-instance-id"
connect_instance_arn       = "your-instance-arn"
connect_queue_general_id   = "your-general-queue-id"
connect_queue_claims_id    = "your-claims-queue-id"
connect_chat_flow_id       = "your-chat-flow-id"
connect_voice_flow_id      = "your-voice-flow-id"

# Amazon Cognito
cognito_user_pool_id       = "your-user-pool-id"
cognito_user_pool_arn      = "your-user-pool-arn"

# Amazon Lex
lex_bot_id                 = "your-bot-id"
lex_bot_alias_id           = "your-bot-alias-id"

# Frontend Origins
portal_origin              = "https://your-portal-domain"
ccp_origin                 = "https://your-ccp-domain"
admin_origin               = "https://your-admin-domain"
```

## Deployment

### Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0
3. Lambda deployment package (`kk-backend.zip`) in `./lambda_function/` directory
4. KMS key created (referenced as `module.common_aws_kms_key`)

### Deployment Steps

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file="environments/${ENV}/terraform.tfvars"

# Apply the configuration
terraform apply -var-file="environments/${ENV}/terraform.tfvars"
```

### Post-Deployment

1. Note the API Gateway endpoint URL from outputs
2. Update frontend applications with the new API endpoint
3. Test health check endpoint: `GET /health`
4. Verify Lambda functions in AWS Console
5. Check CloudWatch Logs for any errors

## Monitoring

### CloudWatch Logs

Each Lambda function has its own log group:
- `/aws/lambda/kk-backend-${env}-${function-name}`

### Metrics

Monitor the following CloudWatch metrics:
- Lambda invocations, errors, duration
- API Gateway 4xx/5xx errors, latency
- DynamoDB read/write capacity, throttles

### Alarms

Consider setting up alarms for:
- Lambda error rate > 5%
- API Gateway 5xx errors
- DynamoDB throttling events
- Lambda concurrent executions approaching limit

## Security

### Encryption
- All DynamoDB tables encrypted with KMS
- S3 bucket encrypted with AES256
- Lambda environment variables encrypted

### Access Control
- IAM roles follow least privilege principle
- API Gateway has no authentication (handled by application)
- DynamoDB tables have fine-grained access control

### Network
- Lambda functions run in AWS-managed VPC
- API Gateway uses EDGE endpoint type
- CORS configured for specific origins

## Cost Optimization

- DynamoDB uses PAY_PER_REQUEST billing
- Lambda functions have appropriate memory/timeout settings
- API Gateway caching can be enabled for read-heavy endpoints
- CloudWatch Logs retention should be configured

## Troubleshooting

### Common Issues

1. **Lambda Timeout**: Increase timeout for specific functions
2. **DynamoDB Throttling**: Check capacity mode and indexes
3. **API Gateway 403**: Verify Lambda permissions
4. **CORS Errors**: Check API Gateway CORS configuration

### Debug Steps

1. Check CloudWatch Logs for Lambda errors
2. Verify IAM role permissions
3. Test Lambda functions directly in console
4. Check API Gateway execution logs
5. Verify environment variables

## Maintenance

### Regular Tasks

- Review and rotate KMS keys
- Update Lambda runtime versions
- Review and optimize DynamoDB indexes
- Clean up old CloudWatch Logs
- Update Lambda deployment packages

### Backup

- DynamoDB Point-in-Time Recovery enabled (7 days)
- S3 versioning enabled for deployment bucket
- Consider exporting DynamoDB tables to S3 for long-term backup

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Amazon DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [Amazon API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [Amazon Connect Documentation](https://docs.aws.amazon.com/connect/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
