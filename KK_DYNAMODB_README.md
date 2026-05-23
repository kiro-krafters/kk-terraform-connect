# KK DynamoDB Tables

## Overview
This configuration creates 4 DynamoDB tables for the KK project using the `kk-terraform-modules-wrapper`.

## Tables

### 1. kk_chat_sessions_dev
- **Purpose**: Active/past portal chat sessions
- **Hash Key**: sessionId (String)
- **Range Key**: timestamp (Number)
- **GSI**: CustomerIdIndex (customerId + timestamp)
- **TTL**: Enabled on expirationTime

### 2. kk_contact_history_dev
- **Purpose**: Contact history per customer
- **Hash Key**: customerId (String)
- **Range Key**: contactTimestamp (Number)
- **GSI**: ContactIdIndex (contactId)

### 3. kk_callbacks_dev
- **Purpose**: Callback requests
- **Hash Key**: callbackId (String)
- **Range Key**: requestedTime (Number)
- **GSI**: CustomerIdIndex, StatusIndex
- **TTL**: Enabled on expirationTime

### 4. kk_audit_logs_dev
- **Purpose**: Admin action audit trail
- **Hash Key**: logId (String)
- **Range Key**: timestamp (Number)
- **GSI**: AdminUserIdIndex, ActionTypeIndex

## Module Source
```hcl
source = "git@github.com:kiro-krafters/kk-terraform-modules-wrapper.git//terraform-aws-dynamodb-table-wrapper?ref=v1.0.0"
```

## Features
- ✅ KMS Encryption enabled
- ✅ Point-in-time recovery (7 days)
- ✅ Deletion protection enabled
- ✅ Pay-per-request billing
- ✅ Created only in primary region (us-east-1)

## Deployment
```bash
cd resources
terraform init
terraform plan -var-file="../environments/dev/us-east-1/inputs.tfvars"
terraform apply -var-file="../environments/dev/us-east-1/inputs.tfvars"
```

## File Location
`resources/dynamodb.tf`
