module "cases_glue_database" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-glue/modules/glue-catalog-database?ref=v1.0.0"

  catalog_database_name        = format("%s-glue-cases-db-%s-%s", var.company_prefix, local.region_prefix, var.env)
  catalog_database_description = "Database for Amazon Connect Cases events and CTR records from connect"
  location_uri                 = format("s3://%s/", module.s3_glue_database_storage.bucket_id)
  tags                         = local.tags
}

module "cases_events_raw_table" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-glue/modules/glue-catalog-table?ref=v1.0.0"

  catalog_table_name        = "cases_events_raw"
  catalog_table_description = "Raw Amazon Connect Cases events table"
  database_name             = module.cases_glue_database.name
  table_type                = "EXTERNAL_TABLE"

  parameters = {
    compressionType = "gzip"
  }

  # use the ordered map built in locals (see comment above)
  partition_keys = local.cases_events_partition_keys

  storage_descriptor = {
    location      = format("s3://%s/cases-events/", module.s3_cases_events.bucket_id)
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = true

    ser_de_info = {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns = [
      {
        name = "timestamp"
        type = "string"
      },
      {
        name = "event_id"
        type = "string"
      },
      {
        name = "event_type"
        type = "string"
      },
      {
        name = "region"
        type = "string"
      },
      {
        name = "performed_by_agent"
        type = "string"
      },
      {
        name = "details"
        type = "string"
      }
    ]
  }
}

module "connect_ctr_raw_table" {
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-glue/modules/glue-catalog-table?ref=v1.0.0"

  catalog_table_name        = "connect_ctr_raw"
  catalog_table_description = "Raw Amazon Connect Contact Trace Records (CTR)"
  database_name             = module.cases_glue_database.name
  table_type                = "EXTERNAL_TABLE"

  parameters = {
    classification = "json"
  }

  storage_descriptor = {
    location      = format("s3://%s/amazon/connect/contact-trace-records/", module.s3_contact_trace_records.bucket_id)
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"
    compressed    = false

    ser_de_info = {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "case.insensitive" = "true"
      }
    }

    columns = [
      { name = "awsaccountid", type = "string" },
      { name = "awscontacttracerecordformatversion", type = "string" },
      { name = "contactid", type = "string" },
      { name = "contactassociationid", type = "string" },
      { name = "initialcontactid", type = "string" },
      { name = "previouscontactid", type = "string" },
      { name = "nextcontactid", type = "string" },
      { name = "instancearn", type = "string" },
      { name = "channel", type = "string" },
      { name = "initiationmethod", type = "string" },
      { name = "initiationtimestamp", type = "string" },
      { name = "connectedtosystemtimestamp", type = "string" },
      { name = "disconnecttimestamp", type = "string" },
      { name = "lastupdatetimestamp", type = "string" },
      { name = "scheduledtimestamp", type = "string" },
      { name = "transfercompletedtimestamp", type = "string" },
      { name = "disconnectreason", type = "string" },
      { name = "agentconnectionattempts", type = "int" },
      { name = "queue", type = "struct<arn:string,name:string,duration:int,enqueuetimestamp:string,dequeuetimestamp:string>" },
      { name = "customerendpoint", type = "struct<address:string,type:string>" },
      { name = "systemendpoint", type = "struct<address:string,type:string>" },
      { name = "transferredtoendpoint", type = "struct<address:string,type:string>" },
      { name = "agent", type = "struct<arn:string,username:string,routingprofile:struct<arn:string,name:string>,hierarchygroups:map<string,string>,connectedtoagenttimestamp:string,aftercontactworkstarttimestamp:string,aftercontactworkendtimestamp:string,aftercontactworkduration:int,agentinteractionduration:int,agentinitiatedholdduration:int,customerholdduration:int,numberofholds:int,longestholdduration:int,deviceinfo:struct<operatingsystem:string,platformname:string,platformversion:string>,statetransitions:array<struct<state:string,timestamp:string>>>" },
      { name = "attributes", type = "map<string,string>" },
      { name = "mediastreams", type = "array<struct<type:string>>" },
      { name = "chatmetrics", type = "struct<agentmetrics:struct<conversationabandon:boolean,messagelengthinchars:int,messagessent:int,numresponses:int,participantid:string,participanttype:string>,contactmetrics:struct<conversationclosetimeinmillis:bigint,conversationturncount:int,multiparty:boolean,totalbotmessagelengthinchars:int,totalbotmessages:int,totalmessages:int>,customermetrics:struct<conversationabandon:boolean,lastmessagetimestamp:string,messagelengthinchars:int,messagessent:int,numresponses:int,participantid:string,participanttype:string>>" },
      { name = "recordings", type = "array<struct<deletionreason:string,location:string,mediastreamtype:string,participanttype:string,starttimestamp:string,stoptimestamp:string,status:string,storagetype:string>>" },
      { name = "recording", type = "struct<deletionreason:string,location:string,status:string,type:string>" },
      { name = "references", type = "array<struct<name:string,status:string,type:string,value:string>>" },
      { name = "campaign", type = "struct<campaignid:string>" },
      { name = "qualitymetrics", type = "struct<agent:struct<audio:struct<potentialqualityissues:array<string>,qualityscore:double>>>" },
      { name = "segmentattributes", type = "map<string,struct<valuearn:string,valueinteger:int,valuelist:array<struct<valuearn:string,valueinteger:int,valuelist:array<string>,valuemap:map<string,string>,valuestring:string>>,valuemap:map<string,string>,valuestring:string>>" },
      { name = "contactdetails", type = "map<string,string>" },
      { name = "customervoiceactivity", type = "map<string,string>" },
      { name = "tasktemplateinfo", type = "struct<id:string,arn:string,name:string>" },
      { name = "voiceidresult", type = "string" },
      { name = "tags", type = "map<string,string>" },
      { name = "answeringmachinedetectionstatus", type = "string" }
    ]
  }
}

module "cases_events_crawler" {
  # use the local copy of the glue-crawler module
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules.git//terraform-aws-glue/modules/glue-crawler?ref=v1.0.0"

  crawler_name        = format("cb-glue-crawler-cases-events-%s-%s", local.region_prefix, var.env)
  crawler_description = "Update partitions on cases_events_raw_new table"
  database_name       = module.cases_glue_database.name
  role                = module.glue_service_role.iam_role_arn

  # run daily at 11:40 UTC
  schedule = "cron(40 11 * * ? *)"

  # keep table schema unchanged, only log schema diffs
  schema_change_policy = {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      CrawlerOutput = {
        Partitions = {
          AddOrUpdateBehavior = "InheritFromTable"
        }
      }
      Version = 1
    }
  )

  catalog_target = [
    {
      database_name = module.cases_glue_database.name
      tables        = [module.cases_events_raw_table.name]
    }
  ]

  tags = local.tags
}
