MON-4697: TM-HAA-13 – RDS Audit Logging Tampering Detection

Classification
Internal

Summary
This rule detects modifications to AWS RDS parameter groups that impact database auditing and logging, particularly focusing on PostgreSQL audit controls (pgaudit) and related logging parameters. Such changes may indicate attempts to disable audit visibility and evade detection.

Status

Status: Production
Enabled in XSIAM: Yes
Severity: High / Critical (dynamic)
Owner: SOC / Cloud Security & Database Security Team
Jira master use case: TM-HAA-13
XSIAM rule ID: (to be populated)


Detection Objective
Identify unauthorised or suspicious changes to RDS database audit configurations, which could allow attackers or insiders to:

Disable logging of database activity
Evade monitoring and detection controls
Conduct unauthorised data access or exfiltration without traceability


Data Sources

AWS CloudTrail (aws_cloudtrail_raw / amazon_aws_raw)
AWS RDS API logs
Cloud audit logs


Rule Logic
The rule monitors AWS CloudTrail logs for activity related to RDS parameter group modifications, specifically targeting logging and audit-related configurations.

1. Targeted Events
The rule triggers on the following API operations:

ModifyDBParameterGroup
ModifyDBClusterParameterGroup
ResetDBParameterGroup


2. Audit/Logging Parameter Monitoring
It focuses on sensitive parameters associated with auditing and logging:

pgaudit
shared_preload_libraries
log_statement
log_min_duration_statement
log_connections
log_disconnections
log_destination
logging_collector

These parameters control:

Query logging
Connection tracking
Audit extension behaviour


3. Approved Role Exclusion
To reduce noise, the rule excludes known trusted administrative roles:

e.g., approved-dba-role


4. Field Standardisation
Standard SOC field mappings are applied:

action → event name
actor_details → user identity
request_details → request parameters
event_ids → event ID


5. Aggregation
Events are grouped by:

User identity
Request parameters

Providing:

Time window (earliest/latest)
Action history
Event types and IDs


6. Detection Reasoning
The rule explicitly identifies higher-risk behaviour such as:

Modification of shared_preload_libraries without including pgaudit
→ Indicates audit extension may have been removed

Otherwise, it flags general audit/logging parameter modifications.

7. Severity Classification
Dynamic severity is assigned based on risk:


Critical:

Audit framework potentially disabled (pgaudit removed)



High:

Multiple modifications detected (≥ 3 events)



Medium:

Single or low-volume changes




Detection Use Cases

Insider threat disabling database auditing
Compromised AWS account modifying logging controls
Attempt to hide unauthorised database queries
Precursor to data exfiltration or manipulation
Compliance evasion (loss of audit trail)


Threat Context / Risk
RDS audit logging provides critical forensic visibility into database activity. If tampered with:

Non-repudiation is lost
Sensitive queries (e.g., user credentials, tokens) may go unlogged
Attackers can operate without detection inside the database layer

Example attack scenario:

Attacker gains access to AWS console or IAM role
Modifies RDS parameter group
Removes or disables pgaudit
Executes queries against sensitive tables without generating logs


MITRE ATT&CK Mapping

T1562.001 – Impair Defenses: Disable or Modify Tools


Limitations / Notes


Requires accurate identification of:

Approved DBA roles
Expected parameter configurations



May generate alerts for:

Legitimate maintenance or tuning activities



Detection fidelity can be improved by:

Correlating with change management approvals
Monitoring subsequent database query patterns
Alerting on log volume drops post-change


Detailed XQL
Detailed query logic is stored in:
query.xql
