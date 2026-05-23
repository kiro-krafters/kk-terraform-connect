module "kinesis" {
  source              = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-kinesis-stream-wrapper?ref=v1.0.6"
  kinesis_stream_name = format("%s-customer-stream-%s-%s", var.company_prefix, local.region_prefix, var.env)
  #shard_count               = 1
  retention_period          = 24
  shard_level_metrics       = ["IncomingBytes", "OutgoingBytes"]
  enforce_consumer_deletion = false
  encryption_type           = "KMS"
  kms_key_id                = module.common_aws_kms_key.key_id
  create_policy_read_only   = true
  create_policy_write_only  = true
  create_policy_admin       = true
  tags                      = local.tags
}
