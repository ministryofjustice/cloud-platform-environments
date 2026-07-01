/*
   TM-HAA-13 – RDS Audit Logging Tampering Detection (Standardised)

   Detects:
   - Modifications to RDS Parameter Groups impacting audit/logging
   - Specifically targeting PostgreSQL audit controls (pgaudit, logging)

   FIELD STANDARD:
   action            → eventname
   actor_details     → userIdentity
   request_details   → requestParameters
   event_ids         → eventID
*/


// ==================================================================================================
// STEP 1 – DATA SOURCE
// ==================================================================================================
dataset = amazon_aws_raw


// ==================================================================================================
// STEP 2 – FILTER – RDS PARAMETER GROUP EVENTS
// ==================================================================================================
| filter eventsource = "rds.amazonaws.com"

| filter eventname = "ModifyDBParameterGroup"
    or eventname = "ModifyDBClusterParameterGroup"
    or eventname = "ResetDBParameterGroup"


// ==================================================================================================
// STEP 3 – FILTER – AUDIT / LOGGING RELATED PARAMETERS
// ==================================================================================================
| filter requestParameters contains "pgaudit"
    or requestParameters contains "shared_preload_libraries"
    or requestParameters contains "log_statement"
    or requestParameters contains "log_min_duration_statement"
    or requestParameters contains "log_connections"
    or requestParameters contains "log_disconnections"
    or requestParameters contains "log_destination"
    or requestParameters contains "logging_collector"


// ==================================================================================================
// STEP 4 – EXCLUDE APPROVED ADMIN ROLES
// ==================================================================================================
| filter userIdentity not contains "approved-dba-role"


// ==================================================================================================
// STEP 5 – DERIVE CORE FIELDS
// ==================================================================================================
| alter action = eventname


// ==================================================================================================
// STEP 6 – AGGREGATION – STANDARD STRUCTURE
// ==================================================================================================
| comp earliest(_time) as earliest,
       latest(_time) as latest,
       count() as count,
       values(action) as actions,
       values(eventID) as event_ids,
       values(eventname) as event_types
       by userIdentity, requestParameters


// ==================================================================================================
// STEP 7 – DETECTION REASON 
// ==================================================================================================
| alter detection_reason =
    if(requestParameters contains "shared_preload_libraries"
       and requestParameters not contains "pgaudit",
       "shared_preload_libraries modified without pgaudit",
       "RDS audit/logging parameter modified")


// ==================================================================================================
// STEP 8 – SEVERITY CLASSIFICATION
// ==================================================================================================
| alter severity_level =
    if(detection_reason contains "without pgaudit", "critical",
    if(count >= 3, "high", "medium"))


// ==================================================================================================
// OUTPUT – STANDARDISED FIELD MAPPING
// ==================================================================================================
| fields earliest,
         latest,
         count,
         actions,
         event_types,
         detection_reason,
         severity_level,
         event_ids,
         userIdentity as actor_details,
         requestParameters as request_details
