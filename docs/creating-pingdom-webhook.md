# Overview

The intention of this document is to provide brief instructions on how to create an integration id in Pingdom. For more information on integration id's, please see Pingdom's documentation: https://help.pingdom.com/hc/en-us/articles/207081599-Webhooks-or-Slack-Integration

## How to create integration id (webhook)

This cannot be managed by Terraform and will need to be created manually. To continue any further it is assumed you have the following:

- Access to the [Pingdom slack app](https://slack.com/apps/A0F814AV7-pingdom?next_id=0)
- Access to Pingdom

To create the webhook perform the following:

<<<<<<< HEAD
<<<<<<< HEAD

- Sign into the mojds Slack [Pingdom app](https://mojdt.slack.com/apps/new/A0F814AV7-pingdom)
- Create a new configuration:

  1. Select the target slack channel
  2. Click 'Add Pingdom Integration'
  3. Find the generated Webhook URL, and copy to clipboard (will look similar to https://hooks.slack.com/services/xxxxxx/xxxxxx/xxxxx)

- Sign into [Pingdom](https://my.pingdom.com/app)
- Go to Settings cog in side menu > `Integrations` > `Add integration`
- Fill in a suitable name for the integration, and paste the generated webhook from previous step
- Save integration

# Now it's a simple case of finding the `integrationid`, which can be found by clicking your newly created integration and making a note of the `integration=` in the URL.

=======

> > > > > > > 4c4ae243ef79be77d8faddb3596f435fd46bb2ab

- Sign into the mojds slack [Pingdom app](https://slack.com/apps/A0F814AV7-pingdom?next_id=0)
- Create a new configuration and generate a webhook url i.e. https://hooks.slack.com/services/xxxxxx/xxxxxx/xxxxx
- Sign into Pingdom
- Go to `integrations` > `add integration`
- Fill in the name and paste you generated webhook and save

Now it's a simple case of finding the `integrationid`, which can be found by clicking your newly created integration and making a note of the `integration` in the URL.
<<<<<<< HEAD

> > > > > > > # 4c4ae243e (Commit changes made by code formatters)
> > > > > > >
> > > > > > > 4c4ae243ef79be77d8faddb3596f435fd46bb2ab

```
e.g.
https://my.pingdom.com/integrations/settings#integration=90679
```
