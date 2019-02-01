Prisoner Money
==============

Architecture
------------

- each MTP namespace defines it’s own AWS resources that are not shared
    - currently, only RDS is terraform-managed
- only the `money-to-prisoners-prod` namespace defines a single ECR shared by all MTP namespaces
    - the associated kubernetes secret is only accessible from the outside in this namespace
    - this single ECR will store images for all MTP apps to simplify deployment

Deployment pipeline
-------------------

See https://github.com/ministryofjustice/money-to-prisoners-deploy
