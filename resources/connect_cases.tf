module "connect_cases_stack" {
  count        = var.is_primary ? 1 : 0
  source       = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-cloudformation-wrapper?ref=v1.0.0"
  name         = "${var.company_prefix}-connect-cases-stack-${local.region_prefix}-${var.env}"
  template_url = "https://${var.company_prefix}-s3-cfn-stack-templates-${local.region_prefix}-${var.env}.s3.${var.region}.amazonaws.com/${local.region_prefix}/cases/cb-cases-field-template-${local.file_hash_map["cases_field_and_templates.yaml"]}.yaml"
  parameters = {
    pCasesDomainId       = var.cases_domain_id
    pCustomerFieldId     = local.cases_system_fields.customer_id
    pSummaryFieldId      = local.cases_system_fields.summary
    pAssignedUserFieldId = local.cases_system_fields.assigned_user
  }
  depends_on = [module.s3_cfn_objects]
}

resource "null_resource" "configure_cases_fields" {
  count = var.is_primary ? 1 : 0

  triggers = {
    domain_id = var.cases_domain_id
    fields    = jsonencode(local.valid_cases_field_options)
    stack_id  = try(module.connect_cases_stack[0].id, "")
  }

  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e
      
      echo "=========================================="
      echo "Assuming Deployment Role"
      echo "=========================================="
      
      # Determine deployment role name
      DEPLOYMENT_ROLE_NAME="cb-iam-shared-deployment-role-${var.env}"
      DEPLOYMENT_ROLE_ARN="arn:aws:iam::${var.account_number}:role/$DEPLOYMENT_ROLE_NAME"
      
      echo "Assuming role: $DEPLOYMENT_ROLE_ARN"
      
      # Get temporary credentials
      CREDENTIALS=$(aws sts assume-role \
        --role-arn "$DEPLOYMENT_ROLE_ARN" \
        --role-session-name "ConfigureCasesFields-${var.env}" \
        --duration-seconds 3600 \
        --output json)
      
      # Extract credentials
      export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
      export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
      export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')
      
      # Verify we assumed the role correctly
      CALLER_IDENTITY=$(aws sts get-caller-identity)
      CURRENT_ARN=$(echo $CALLER_IDENTITY | jq -r '.Arn')
      CURRENT_ACCOUNT=$(echo $CALLER_IDENTITY | jq -r '.Account')
      
      echo ""
      echo "Credential Verification:"
      echo "   Current ARN: $CURRENT_ARN"
      echo "   Current Account: $CURRENT_ACCOUNT"
      echo "   Expected Account: ${var.account_number}"
      
      # Verify we're using the correct deployment role
      if [[ "$CURRENT_ARN" != *"$DEPLOYMENT_ROLE_NAME"* ]]; then
        echo "ERROR: Not using correct deployment role!"
        echo "   Current ARN: $CURRENT_ARN"
        echo "   Expected role: $DEPLOYMENT_ROLE_NAME"
        exit 1
      fi
      
      if [ "$CURRENT_ACCOUNT" != "${var.account_number}" ]; then
        echo "ERROR: Wrong AWS account!"
        exit 1
      fi
      
      echo "✓ Successfully assumed deployment role in member account"
      
      echo ""
      echo "=========================================="
      echo "Configuring AWS Connect Cases"
      echo "Domain ID: ${var.cases_domain_id}"
      echo "Region: ${var.region}"
      echo "Environment: ${var.env}"
      echo "=========================================="
      
      # Step 1: Enable EventBridge
      echo ""
      echo "Step 1: Enabling EventBridge..."
      aws connectcases put-case-event-configuration \
        --domain-id ${var.cases_domain_id} \
        --event-bridge enabled=true \
        --region ${var.region} 2>&1 && echo "✓ EventBridge enabled successfully" || echo "⚠ EventBridge already enabled (continuing...)"
      
      # Step 2: Batch update field options
      echo ""
      echo "Step 2: Updating field options..."
      TOTAL_FIELDS=${length(local.valid_cases_field_options)}
      CURRENT_FIELD=0
      FAILED_FIELDS=0
      
      %{for field_id, options in local.valid_cases_field_options~}
      CURRENT_FIELD=$((CURRENT_FIELD + 1))
      echo ""
      echo "[$CURRENT_FIELD/$TOTAL_FIELDS] Processing field: ${field_id}"
      
      if aws connectcases batch-put-field-options \
        --domain-id ${var.cases_domain_id} \
        --field-id ${field_id} \
        --options '${jsonencode(options)}' \
        --region ${var.region} 2>&1; then
        echo "✓ Field ${field_id} options updated successfully"
      else
        echo "Field ${field_id} update failed"
        FAILED_FIELDS=$((FAILED_FIELDS + 1))
      fi
      %{endfor~}
      
      echo ""
      echo "=========================================="
      if [ $FAILED_FIELDS -eq 0 ]; then
        echo "✓ Configuration completed successfully"
        echo "   EventBridge: Enabled"
        echo "   Fields configured: $TOTAL_FIELDS/$TOTAL_FIELDS"
      else
        echo "⚠ Configuration completed with errors"
        echo "   EventBridge: Enabled"
        echo "   Fields configured: $((TOTAL_FIELDS - FAILED_FIELDS))/$TOTAL_FIELDS"
        echo "   Failed fields: $FAILED_FIELDS"
        exit 1
      fi
      echo "=========================================="
    EOT

    interpreter = ["bash", "-c"]

    environment = {
      AWS_REGION         = var.region
      AWS_DEFAULT_REGION = var.region
    }
  }

  depends_on = [module.connect_cases_stack]
}

resource "null_resource" "configure_connect_cases_system_fields" {
  
  count = var.is_primary && var.env != "dev" ? 1 : 0

  triggers = {
    domain_id = var.cases_domain_id
    fields    = jsonencode(local.system_managed_field_options)
    env       = var.env
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]

    command = <<-EOT
      set -e

      echo "=========================================="
      echo "Assuming Deployment Role (System Fields)"
      echo "=========================================="

      DEPLOYMENT_ROLE_NAME="cb-iam-shared-deployment-role-${var.env}"
      DEPLOYMENT_ROLE_ARN="arn:aws:iam::${var.account_number}:role/$DEPLOYMENT_ROLE_NAME"

      CREDENTIALS=$(aws sts assume-role \
        --role-arn "$DEPLOYMENT_ROLE_ARN" \
        --role-session-name "ConfigureCasesSystemFields-${var.env}" \
        --duration-seconds 3600 \
        --output json)

      export AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS" | jq -r '.Credentials.AccessKeyId')
      export AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.Credentials.SecretAccessKey')
      export AWS_SESSION_TOKEN=$(echo "$CREDENTIALS" | jq -r '.Credentials.SessionToken')

      CALLER_IDENTITY=$(aws sts get-caller-identity)
      CURRENT_ARN=$(echo "$CALLER_IDENTITY" | jq -r '.Arn')
      CURRENT_ACCOUNT=$(echo "$CALLER_IDENTITY" | jq -r '.Account')

      if [[ "$CURRENT_ARN" != *"$DEPLOYMENT_ROLE_NAME"* ]]; then
        echo "ERROR: Not using deployment role"
        exit 1
      fi

      if [ "$CURRENT_ACCOUNT" != "${var.account_number}" ]; then
        echo "ERROR: Wrong AWS account"
        exit 1
      fi

      echo "✓ Deployment role assumed correctly"

      echo ""
      echo "=========================================="
      echo "Configuring SYSTEM-MANAGED Case Fields"
      echo "Domain ID: ${var.cases_domain_id}"
      echo "Region: ${var.region}"
      echo "=========================================="

      SYSTEM_FIELDS='${jsonencode(local.system_managed_field_options)}'

      echo "$SYSTEM_FIELDS" | jq -c 'to_entries[]' | while read -r entry; do
        FIELD_NAME=$(echo "$entry" | jq -r '.key')
        OPTIONS=$(echo "$entry" | jq -c '.value')

        echo ""
        echo "Resolving field ID for system field: $FIELD_NAME"

        FIELD_ID=$(aws connectcases list-fields \
          --domain-id ${var.cases_domain_id} \
          --region ${var.region} \
          --query "fields[?name=='$FIELD_NAME'].fieldId | [0]" \
          --output text)

        if [[ "$FIELD_ID" == "None" || -z "$FIELD_ID" ]]; then
          echo "ERROR: Field '$FIELD_NAME' not found"
          exit 1
        fi

        aws connectcases batch-put-field-options \
          --domain-id ${var.cases_domain_id} \
          --field-id "$FIELD_ID" \
          --options "$OPTIONS" \
          --region ${var.region}

        echo "✓ Updated $FIELD_NAME"
      done

      echo ""
      echo "✓ System-managed field configuration complete"
    EOT

    environment = {
      AWS_REGION         = var.region
      AWS_DEFAULT_REGION = var.region
    }
  }

  depends_on = [module.connect_cases_stack]
}
