module "connect_prompts_stack" {
  count        = var.is_primary ? 1 : 0
  source       = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-cloudformation-wrapper?ref=v1.0.0"
  name         = "${var.company_prefix}-connect-prompts-stack-${local.region_prefix}-${var.env}"
  template_url = "https://${var.company_prefix}-s3-cfn-stack-templates-${local.region_prefix}-${var.env}.s3.${var.region}.amazonaws.com/${local.region_prefix}/prompts/connect-prompts-template-${local.file_hash_map["connect_prompts.yaml"]}.yaml"
  parameters = {
    pConnectInstanceArn = "arn:aws:connect:${var.region}:${var.account_number}:instance/${local.connect_instance_id}"
    pBucketName         = "${var.company_prefix}-s3-connect-prompts-${local.region_prefix}-${var.env}"

    pOffForHolidaysPromptKey                   = local.s3_prompt_objects_map["object1"].key
    pOutOfHoursPromptKey                       = local.s3_prompt_objects_map["object2"].key
    pSilencePromptKey                          = local.s3_prompt_objects_map["object3"].key
    pInboundCallNavigatorsBusyPromptKey        = local.s3_prompt_objects_map["object4"].key
    pInboundCallConnectingToNavigatorPromptKey = local.s3_prompt_objects_map["object5"].key

  }
  depends_on = [module.s3_prompt_objects]
}
