locals {
  # Athena Views for Cases Events Data
  # View 1: Flattened JSON details into proper columns
  athena_view_flat_sql = <<SQL
CREATE OR REPLACE VIEW "${local.cases_database_name}"."cases_events_flat" AS 
SELECT
  event_id,
  event_type,
  date_format(from_iso8601_timestamp(timestamp), '%Y-%m-%d %H:%i:%s') event_timestamp,
  region,
  performed_by_agent,
  year,
  month,
  day,
  json_extract_scalar(details, '$.case_id') case_id,
  json_extract_scalar(details, '$.template_id') template_id,
  json_extract_scalar(details, '$.case_created_datetime') case_created_datetime,
  json_extract_scalar(details, '$["customer id"]') customer_id,
  json_extract_scalar(details, '$.gender') gender,
  json_extract_scalar(details, '$.race') race,
  json_extract_scalar(details, '$.ethnicity') ethnicity,
  json_extract_scalar(details, '$.age') age,
  json_extract_scalar(details, '$["zip code"]') zip_code,
  json_extract_scalar(details, '$.county') county,
  json_extract_scalar(details, '$["Are you calling for yourself or someone else?"]') are_you_calling_for_youself_or_someone_else,
  json_extract_scalar(details, '$["sms consent"]') sms_consent,
  json_extract_scalar(details, '$["assigned user"]') assigned_user,
  json_extract_scalar(details, '$["callback required"]') callback_required,
  json_extract_scalar(details, '$["call back due"]') call_back_due,
  json_extract_scalar(details, '$["referral #1"]') referral_1,
  json_extract_scalar(details, '$["referral #2"]') referral_2,
  json_extract_scalar(details, '$["interested in : treatment for meth"]') interested_in_treatment_for_meth,
  json_extract_scalar(details, '$["interested in : residential treatment"]') interested_in_residential_treatment,
  json_extract_scalar(details, '$["interested in : methadone"]') interested_in_methadone,
  json_extract_scalar(details, '$["interested in : treatment for other substances"]') interested_in_treatment_for_other_substances,
  json_extract_scalar(details, '$["interested in : overdose prevention supplies"]') interested_in_overdose_prevention_supplies,
  json_extract_scalar(details, '$["interested in : reproductive health"]') interested_in_reproductive_health,
  json_extract_scalar(details, '$["interested in : buprenorphrine"]') interested_in_buprenorphrine,
  json_extract_scalar(details, '$["interested in : detox"]') interested_in_detox,
  json_extract_scalar(details, '$["interested in : reconnect to services"]') interested_in_reconnect_to_services,
  json_extract_scalar(details, '$["interested in : hiv/hep c"]') interested_in_hiv_hep_c,
  json_extract_scalar(details, '$["interested in : mental health resources"]') interested_in_mental_health_resources,
  json_extract_scalar(details, '$["interested in : treatment for alcohol"]') interested_in_treatment_for_alcohol,
  json_extract_scalar(details, '$["insurance preferences"]') insurance_preferences,
  json_extract_scalar(details, '$["barrier to treatment : time constraints due to working or care of family friend"]') barrier_time_constraints,
  json_extract_scalar(details, '$["barrier to treatment : transportation"]') barrier_transportation,
  json_extract_scalar(details, '$["barrier to treatment : insurance money challenges"]') barrier_insurance_money,
  json_extract_scalar(details, '$["barrier to treatment : reported contact with unfriendly staff"]') barrier_unfriendly_staff,
  json_extract_scalar(details, '$["barrier to treatment : no evening access"]') barrier_no_evening_access,
  json_extract_scalar(details, '$["barrier to treatment : arrest incarceration"]') barrier_arrest_incarceration,
  json_extract_scalar(details, '$["barrier to treatment : homeless or unstable housing"]') barrier_homeless_unstable_housing,
  json_extract_scalar(details, '$["barrier to treatment : other"]') barrier_other,
  json_extract_scalar(details, '$["navigation outcome : referral to cdc get tested website"]') nav_referral_cdc,
  json_extract_scalar(details, '$["navigation outcome : referral to emergency department"]') nav_referral_emergency_department,
  json_extract_scalar(details, '$["navigation outcome : referral for other social services"]') nav_referral_other_social_services,
  json_extract_scalar(details, '$["navigation outcome : no referral, information only"]') nav_no_referral_information_only,
  json_extract_scalar(details, '$["navigation outcome : referral for methadone"]') nav_referral_methadone,
  json_extract_scalar(details, '$["navigation outcome : no referral, outside service area"]') nav_no_referral_outside_service_area,
  json_extract_scalar(details, '$["navigation outcome : no referral, irrelevant"]') nav_no_referral_irrelevant,
  json_extract_scalar(details, '$["navigation outcome : referral for residential treatment"]') nav_referral_residential,
  json_extract_scalar(details, '$["navigation outcome : referral to 211"]') nav_referral_211,
  json_extract_scalar(details, '$["navigation outcome : no referral, out of scope"]') nav_no_referral_out_of_scope,
  json_extract_scalar(details, '$["navigation outcome : referral to 911"]') nav_referral_911,
  json_extract_scalar(details, '$["navigation outcome : referral to county access line"]') nav_referral_county_access_line,
  json_extract_scalar(details, '$["navigation outcome : referral to clinic"]') nav_referral_clinic,
  json_extract_scalar(details, '$["navigation outcome : referral to hiv.gov"]') nav_referral_hiv_gov,
  json_extract_scalar(details, '$["navigation outcome : referral to telemedicine"]') nav_referral_telemedicine,
  json_extract_scalar(details, '$["navigation outcome : no referral, referral refused"]') nav_no_referral_refused,
  json_extract_scalar(details, '$["navigation outcome : referral for overdose prevention supplies"]') nav_referral_overdose_supplies,
  json_extract_scalar(details, '$["navigation outcome : referral for buprenorphine"]') nav_referral_buprenorphine,
  json_extract_scalar(details, '$["fu non-mat : did you get what you needed from our call?"]') fu_non_mat_got_needed,
  json_extract_scalar(details, '$["fu non-mat : are you interested in a referral to mat?"]') fu_non_mat_interested_in_mat,
  json_extract_scalar(details, '$["fu mat day 1 : did you go to the referral site?"]') fu_day1_went_to_referral,
  json_extract_scalar(details, '$["fu mat day 1 : notes"]') fu_day1_notes,
  json_extract_scalar(details, '$["fu mat day 1 : where is fu appt?"]') fu_day1_where_appt,
  json_extract_scalar(details, '$["fu mat day 1 : were you able to get the treatment?"]') fu_day1_got_treatment,
  json_extract_scalar(details, '$["fu mat day 1 : do you have a follow-up appt scheduled?"]') fu_day1_followup_scheduled,
  json_extract_scalar(details, '$["fu mat day 30 : are you planning to/did you attend a follow-up appointment?"]') fu_day30_attended,
  json_extract_scalar(details, '$["fu mat day 30 : are you still taking [mat]?"]') fu_day30_still_mat,
  json_extract_scalar(details, '$["fu mat day 30 : notes"]') fu_day30_notes,
  json_extract_scalar(details, '$["fu mat day 30 : where is fu appt?"]') fu_day30_where_appt,
  json_extract_scalar(details, '$["fu mat day 60 : notes"]') fu_day60_notes,
  json_extract_scalar(details, '$["fu mat day 60 : where is fu appt?"]') fu_day60_where_appt,
  json_extract_scalar(details, '$["fu mat day 60 : are you still taking [mat]?"]') fu_day60_still_mat,
  json_extract_scalar(details, '$["fu mat day 60 : are you planning to/did you attend a follow-up appointment?"]') fu_day60_attended,
  json_extract_scalar(details, '$["fu mat day 90 : where is fu appt?"]') fu_day90_where_appt,
  json_extract_scalar(details, '$["fu mat day 90 : notes"]') fu_day90_notes,
  json_extract_scalar(details, '$["fu mat day 90 : are you still taking [mat]?"]') fu_day90_still_mat,
  json_extract_scalar(details, '$["fu mat day 90 : are you planning to/did you attend a follow-up appointment?"]') fu_day90_attended,
  json_extract_scalar(details, '$.summary') summary,
  json_extract_scalar(details, '$.status') status
FROM
  "${local.cases_database_name}"."${module.cases_events_raw_table.name}"
WHERE 
  ((json_extract_scalar(details, '$.case_id') IS NOT NULL) 
   AND (trim(BOTH FROM json_extract_scalar(details, '$.case_id')) <> '') 
   AND (event_type <> 'RELATED_ITEM.CREATED'))
SQL

  # View 2: Latest event state per case
  athena_view_latest_sql = <<SQL
CREATE OR REPLACE VIEW "${local.cases_database_name}"."cases_latest" AS 
WITH latest_event AS (
   SELECT
     case_id,
     MAX(parse_datetime(event_timestamp, 'yyyy-MM-dd HH:mm:ss')) latest_event_time
   FROM
     "${local.cases_database_name}"."cases_events_flat"
   WHERE (case_id IS NOT NULL)
   GROUP BY case_id
),
latest_event_with_tie_break AS (
   SELECT
     e.case_id,
     MAX(e.event_id) latest_event_id
   FROM
     ("${local.cases_database_name}"."cases_events_flat" e
   INNER JOIN latest_event l ON ((e.case_id = l.case_id) AND (parse_datetime(e.event_timestamp, 'yyyy-MM-dd HH:mm:ss') = l.latest_event_time)))
   GROUP BY e.case_id
)
SELECT e.*
FROM
  ("${local.cases_database_name}"."cases_events_flat" e
INNER JOIN latest_event_with_tie_break t ON ((e.case_id = t.case_id) AND (e.event_id = t.latest_event_id)))
SQL
  # View 3: Flattened Contact Trace Records with enriched attributes and metadata
  athena_view_ctr_flat_sql = <<SQL
CREATE OR REPLACE VIEW "${local.cases_database_name}"."connect_ctr_flat" AS
SELECT
  contactid AS contact_id,
  contactassociationid AS contact_association_id,
  initialcontactid AS initial_contact_id,
  previouscontactid AS previous_contact_id,
  nextcontactid AS next_contact_id,
  awsaccountid AS aws_account_id,
  awscontacttracerecordformatversion,
  instancearn,
  channel,
  initiationmethod AS initiation_method,
  initiationtimestamp AS initiation_timestamp,
  connectedtosystemtimestamp AS connected_to_system_timestamp,
  disconnecttimestamp AS disconnect_timestamp,
  lastupdatetimestamp AS last_update_timestamp,
  scheduledtimestamp AS scheduled_timestamp,
  transfercompletedtimestamp AS transfer_completed_timestamp,
  disconnectreason AS disconnect_reason,
  agentconnectionattempts AS agent_connection_attempts,
  answeringmachinedetectionstatus AS answering_machine_detection_status,
  queue.arn                AS queue_arn,
  queue.name               AS queue_name,
  queue.duration           AS queue_duration_sec,
  queue.enqueuetimestamp   AS queue_enqueue_timestamp,
  queue.dequeuetimestamp   AS queue_dequeue_timestamp,
  customerendpoint.address AS customer_phone,
  customerendpoint.type    AS customer_endpoint_type,
  systemendpoint.address   AS system_endpoint_address,
  systemendpoint.type      AS system_endpoint_type,
  transferredtoendpoint.address AS transferred_to_phone,
  transferredtoendpoint.type    AS transferred_to_type,
  agent.arn                AS agent_arn,
  agent.username           AS agent_username,
  agent.connectedtoagenttimestamp        AS agent_connected_timestamp,
  agent.aftercontactworkstarttimestamp   AS agent_after_contact_work_start_timestamp,
  agent.aftercontactworkendtimestamp     AS agent_after_contact_work_end_timestamp,
  agent.aftercontactworkduration    AS agent_after_contact_work_duration_sec,
  agent.agentinteractionduration    AS agent_talk_time_sec,
  agent.agentinitiatedholdduration  AS agent_agent_hold_duration_sec,
  agent.customerholdduration        AS agent_customer_hold_duration_sec,
  agent.numberofholds               AS agent_hold_count,
  agent.longestholdduration         AS agent_longest_hold_duration_sec,
  agent.deviceinfo.operatingsystem  AS agent_os,
  agent.deviceinfo.platformname     AS agent_browser,
  agent.deviceinfo.platformversion  AS agent_browser_version,
  chatmetrics.contactmetrics.totalmessages AS chat_contact_metrics_total_messages,
  chatmetrics.contactmetrics.totalbotmessages AS chat_contact_metrics_total_bot_messages,
  chatmetrics.contactmetrics.conversationturncount AS chat_contact_metrics_conversation_turn_count,
  chatmetrics.contactmetrics.conversationclosetimeinmillis / 1000 AS chat_contact_metrics_conversation_close_time_sec,
  chatmetrics.customermetrics.messagessent AS chat_customer_metrics_messages_sent,
  chatmetrics.customermetrics.numresponses AS chat_customer_metrics_num_responses,
  chatmetrics.customermetrics.lastmessagetimestamp AS chat_customer_metrics_last_message_timestamp,
  chatmetrics.agentmetrics.messagessent AS chat_agent_metrics_messages_sent,
  chatmetrics.agentmetrics.numresponses AS chat_agent_metrics_num_responses,
  attributes['profilearn']       AS customer_profile_arn,
  regexp_extract(attributes['profilearn'], 'profiles/([^/]+)', 1) AS customer_profile_id,
  attributes['cases_any']        AS has_cases,
  attributes['last_case_status'] AS last_case_status,
  attributes['case_id'] AS case_id,
  attributes['error'] AS error_message,
  recording.location  AS recording_location,
  recording.status    AS recording_status,
  recording.type      AS recording_type,
  cardinality(mediastreams) AS media_stream_count,
  qualitymetrics.agent.audio.qualityscore AS agent_audio_quality_score,
  campaign.campaignid AS campaign_id,
  date_diff('second',from_iso8601_timestamp(connectedtosystemtimestamp),from_iso8601_timestamp(disconnecttimestamp)) AS call_duration_seconds
FROM
"${local.cases_database_name}"."${module.connect_ctr_raw_table.name}"
SQL

  # View 4: Aggregated contacts per case
  athena_view_aggregated_contacts_sql = <<SQL
CREATE OR REPLACE VIEW "${local.cases_database_name}"."aggregated_contacts_view" AS
SELECT
  case_id,
  COUNT(contact_id) AS contact_count,
  COUNT(CASE WHEN channel = 'CHAT' THEN 1 END) AS chat_count,
  COUNT(CASE WHEN channel = 'VOICE' THEN 1 END) AS voice_count,
  SUM(agent_talk_time_sec) / 60 AS total_agent_talk_time_min,
  SUM(agent_after_contact_work_duration_sec) / 60 AS total_agent_after_contact_work_duration_min
FROM
  "${local.cases_database_name}"."connect_ctr_flat"
WHERE
  case_id IS NOT NULL
  AND case_id <> ''
GROUP BY
  case_id
SQL

  # View 5: Case status pathing transitions per case
  athena_view_case_pathing_individual_sql = <<SQL
CREATE OR REPLACE VIEW "${local.cases_database_name}"."case_pathing_individual" AS
WITH deduped AS (
  SELECT DISTINCT
    case_id,
    CAST(event_timestamp AS timestamp) AS event_timestamp,
    status
  FROM
    "${local.cases_database_name}"."cases_events_flat"
  WHERE
    status IS NOT NULL
    AND status <> 'New Voicemail'
),
status_changes AS (
  SELECT
    case_id,
    event_timestamp,
    status,
    LAG(status) OVER (PARTITION BY case_id ORDER BY event_timestamp ASC) AS prev_status
  FROM
    deduped
),
first_occurrences AS (
  SELECT
    case_id,
    event_timestamp,
    status
  FROM
    status_changes
  WHERE
    prev_status IS NULL
    OR prev_status <> status
),
transitions AS (
  SELECT
    case_id,
    status AS source_status,
    LEAD(status) OVER (PARTITION BY case_id ORDER BY event_timestamp ASC) AS target_status,
    CAST(event_timestamp AS timestamp) AS entered_at,
    CAST(LEAD(event_timestamp) OVER (PARTITION BY case_id ORDER BY event_timestamp ASC) AS timestamp) AS exited_at
  FROM
    first_occurrences
)
SELECT
  case_id,
  source_status,
  target_status,
  entered_at,
  exited_at,
  ROUND(date_diff('second', entered_at, exited_at) / 8.64E4, 2) AS days_in_status,
  CASE
    WHEN target_status IS NULL THEN 'Still in stage'
    WHEN target_status IN ('In Progress') AND source_status IN ('open') THEN 'Ideal'
    WHEN target_status IN ('3- Referral Provided') AND source_status IN ('In Progress') THEN 'Ideal'
    WHEN target_status IN ('Follow Up Phase') AND source_status IN ('3- Referral Provided') THEN 'Ideal'
    WHEN target_status IN ('closed', 'Lost to Follow Up', '3a- Lost to referral', '5- Opted Out', 'Unable to Reach') THEN 'Drop-off'
    ELSE 'Deviation'
  END AS transition_type
FROM
  transitions
SQL

  # View 6: Case pathing Sankey transition summary
  athena_view_case_pathing_sankey_sql = <<SQL
CREATE OR REPLACE VIEW "${local.cases_database_name}"."case_pathing_sankey" AS
WITH deduped AS (
  SELECT DISTINCT
    case_id,
    CAST(event_timestamp AS timestamp) AS event_timestamp,
    status
  FROM
    "${local.cases_database_name}"."cases_events_flat"
  WHERE
    status IS NOT NULL
    AND status <> 'New Voicemail'
),
status_changes AS (
  SELECT
    case_id,
    event_timestamp,
    status,
    LAG(status) OVER (PARTITION BY case_id ORDER BY event_timestamp ASC) AS prev_status
  FROM
    deduped
),
first_occurrences AS (
  SELECT
    case_id,
    event_timestamp,
    status
  FROM
    status_changes
  WHERE
    prev_status IS NULL
    OR prev_status <> status
),
transitions AS (
  SELECT
    case_id,
    status AS source_status,
    LEAD(status) OVER (PARTITION BY case_id ORDER BY event_timestamp ASC) AS target_status,
    CAST(event_timestamp AS timestamp) AS entered_at,
    CAST(LEAD(event_timestamp) OVER (PARTITION BY case_id ORDER BY event_timestamp ASC) AS timestamp) AS exited_at
  FROM
    first_occurrences
),
transition_counts AS (
  SELECT
    source_status,
    target_status,
    COUNT(*) AS case_count,
    ROUND(AVG(date_diff('second', entered_at, exited_at) / 8.64E4), 2) AS avg_days_in_status,
    MIN(ROUND(date_diff('second', entered_at, exited_at) / 8.64E4, 2)) AS min_days,
    MAX(ROUND(date_diff('second', entered_at, exited_at) / 8.64E4, 2)) AS max_days
  FROM
    transitions
  WHERE
    exited_at IS NOT NULL
  GROUP BY
    source_status,
    target_status
),
stage_totals AS (
  SELECT
    source_status,
    SUM(case_count) AS total_entered
  FROM
    transition_counts
  GROUP BY
    source_status
)
SELECT
  tc.source_status,
  tc.target_status,
  tc.case_count,
  tc.avg_days_in_status,
  tc.min_days,
  tc.max_days,
  st.total_entered,
  ROUND((1E2 * tc.case_count) / st.total_entered, 1) AS pct_of_entries,
  CASE
    WHEN tc.target_status = 'In Progress' AND tc.source_status = 'open' THEN 'Ideal'
    WHEN tc.target_status = '3- Referral Provided' AND tc.source_status = 'In Progress' THEN 'Ideal'
    WHEN tc.target_status = 'Follow Up Phase' AND tc.source_status = '3- Referral Provided' THEN 'Ideal'
    WHEN tc.target_status IN ('closed', 'Lost to Follow Up', '3a- Lost to referral', '5- Opted Out', 'Unable to Reach') THEN 'Drop-off'
    ELSE 'Deviation'
  END AS transition_type
FROM
  transition_counts tc
  INNER JOIN stage_totals st ON tc.source_status = st.source_status
ORDER BY
  tc.source_status ASC,
  tc.target_status ASC
SQL
}

# -----------------------------------------------------------------------------
# Execute Athena SQL directly to create/update Cases Views
# -----------------------------------------------------------------------------

resource "null_resource" "execute_athena_views" {
  count = var.is_primary ? 1 : 0

  triggers = {
    flat_query_sql_sha     = sha256(local.athena_view_flat_sql)
    latest_query_sql_sha   = sha256(local.athena_view_latest_sql)
    ctr_flat_query_sql_sha = sha256(local.athena_view_ctr_flat_sql)
    aggregated_query_sql_sha = sha256(local.athena_view_aggregated_contacts_sql)
    case_pathing_individual_query_sql_sha = sha256(local.athena_view_case_pathing_individual_sql)
    case_pathing_sankey_query_sql_sha      = sha256(local.athena_view_case_pathing_sankey_sql)
    database_name          = module.cases_glue_database.name
  }

  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e
      
      echo "=========================================="
      echo "Assuming Deployment Role for Athena Views"
      echo "=========================================="
      
      # Determine deployment role name
      DEPLOYMENT_ROLE_NAME="cb-iam-shared-deployment-role-${var.env}"
      DEPLOYMENT_ROLE_ARN="arn:aws:iam::${var.account_number}:role/$DEPLOYMENT_ROLE_NAME"
      
      echo "Assuming role: $DEPLOYMENT_ROLE_ARN"
      
      # Get temporary credentials
      CREDENTIALS=$(aws sts assume-role \
        --role-arn "$DEPLOYMENT_ROLE_ARN" \
        --role-session-name "ExecuteAthenaViews-${var.env}" \
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
      
      echo "✓ Successfully assumed deployment role"
      
      echo ""
      echo "=========================================="
      echo "Executing Athena Views"
      echo "Database: $DATABASE_NAME"
      echo "Region: ${var.region}"
      echo "Environment: ${var.env}"
      echo "=========================================="
      
      # Execute cases_events_flat view
      echo ""
      echo "Executing cases_events_flat view..."
      FLAT_EXECUTION_JSON=$(aws athena start-query-execution \
        --query-string "$FLAT_QUERY_SQL" \
        --query-execution-context Database=$DATABASE_NAME,Catalog=AwsDataCatalog \
        --result-configuration OutputLocation=s3://$RESULT_BUCKET/views/ \
        --work-group primary)
      FLAT_EXECUTION_ID=$(echo "$FLAT_EXECUTION_JSON" | jq -r '.QueryExecutionId')
      
      echo "Flat view execution ID: $FLAT_EXECUTION_ID"
      
      # Execute cases_latest view
      echo ""
      echo "Executing cases_latest view..."
      LATEST_EXECUTION_JSON=$(aws athena start-query-execution \
        --query-string "$LATEST_QUERY_SQL" \
        --query-execution-context Database=$DATABASE_NAME,Catalog=AwsDataCatalog \
        --result-configuration OutputLocation=s3://$RESULT_BUCKET/views/ \
        --work-group primary)
      LATEST_EXECUTION_ID=$(echo "$LATEST_EXECUTION_JSON" | jq -r '.QueryExecutionId')
      
      echo "Latest view execution ID: $LATEST_EXECUTION_ID"
      
      # Execute connect_ctr_flat view
      echo ""
      echo "Executing connect_ctr_flat view..."
      CTR_FLAT_EXECUTION_JSON=$(aws athena start-query-execution \
        --query-string "$CTR_FLAT_QUERY_SQL" \
        --query-execution-context Database=$DATABASE_NAME,Catalog=AwsDataCatalog \
        --result-configuration OutputLocation=s3://$RESULT_BUCKET/views/ \
        --work-group primary)
      CTR_FLAT_EXECUTION_ID=$(echo "$CTR_FLAT_EXECUTION_JSON" | jq -r '.QueryExecutionId')
      
      echo "CTR flat view execution ID: $CTR_FLAT_EXECUTION_ID"

      # Execute aggregated_contacts_view
      echo ""
      echo "Executing aggregated_contacts_view..."
      AGGREGATED_EXECUTION_JSON=$(aws athena start-query-execution \
        --query-string "$AGGREGATED_QUERY_SQL" \
        --query-execution-context Database=$DATABASE_NAME,Catalog=AwsDataCatalog \
        --result-configuration OutputLocation=s3://$RESULT_BUCKET/views/ \
        --work-group primary)
      AGGREGATED_EXECUTION_ID=$(echo "$AGGREGATED_EXECUTION_JSON" | jq -r '.QueryExecutionId')

      echo "Aggregated view execution ID: $AGGREGATED_EXECUTION_ID"

      # Execute case_pathing_individual
      echo ""
      echo "Executing case_pathing_individual..."
      CASE_PATHING_INDIVIDUAL_EXECUTION_JSON=$(aws athena start-query-execution \
        --query-string "$CASE_PATHING_INDIVIDUAL_QUERY_SQL" \
        --query-execution-context Database=$DATABASE_NAME,Catalog=AwsDataCatalog \
        --result-configuration OutputLocation=s3://$RESULT_BUCKET/views/ \
        --work-group primary)
      CASE_PATHING_INDIVIDUAL_EXECUTION_ID=$(echo "$CASE_PATHING_INDIVIDUAL_EXECUTION_JSON" | jq -r '.QueryExecutionId')

      echo "Case pathing individual execution ID: $CASE_PATHING_INDIVIDUAL_EXECUTION_ID"

      # Execute case_pathing_sankey
      echo ""
      echo "Executing case_pathing_sankey..."
      CASE_PATHING_SANKEY_EXECUTION_JSON=$(aws athena start-query-execution \
        --query-string "$CASE_PATHING_SANKEY_QUERY_SQL" \
        --query-execution-context Database=$DATABASE_NAME,Catalog=AwsDataCatalog \
        --result-configuration OutputLocation=s3://$RESULT_BUCKET/views/ \
        --work-group primary)
      CASE_PATHING_SANKEY_EXECUTION_ID=$(echo "$CASE_PATHING_SANKEY_EXECUTION_JSON" | jq -r '.QueryExecutionId')

      echo "Case pathing sankey execution ID: $CASE_PATHING_SANKEY_EXECUTION_ID"

      echo ""
      echo "=========================================="
      echo "✓ All Athena views executed successfully"
      echo "=========================================="
    EOT

    interpreter = ["bash", "-c"]

    environment = {
      AWS_REGION         = var.region
      AWS_DEFAULT_REGION = var.region
      DATABASE_NAME      = module.cases_glue_database.name
      RESULT_BUCKET      = module.s3_athena_query_result_bucket.bucket_id
      FLAT_QUERY_SQL     = local.athena_view_flat_sql
      LATEST_QUERY_SQL   = local.athena_view_latest_sql
      CTR_FLAT_QUERY_SQL = local.athena_view_ctr_flat_sql
      AGGREGATED_QUERY_SQL = local.athena_view_aggregated_contacts_sql
      CASE_PATHING_INDIVIDUAL_QUERY_SQL = local.athena_view_case_pathing_individual_sql
      CASE_PATHING_SANKEY_QUERY_SQL = local.athena_view_case_pathing_sankey_sql
    }
  }

  depends_on = [
    module.cases_events_crawler
  ]
}
