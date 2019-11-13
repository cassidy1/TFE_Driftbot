# Terraform Enterprise Drift Detection Bot

This bot was built based on code creat for the (https://github.com/AdamCavaliere/TFE_WorkspaceReaper "Workspace Reaper Bot") which is a great tool for controlling resource costs by removing unused resources. Check it out!

## Application Details

This application is utilized to automatically queue runs on workspaces based on a DRIFTBOT_ENABLED enviornment variable being set. Notifications can be set in Terraform Enterprise to notify you whenever a plan needs to be applied because there was a change to the state outside of TFE.

The application is fully based on Lambda functions, and is automatically deployed via Terraform.

This application is built for demonstration purposes to show interacting with the TFE API and is not built for production usage. For now...

## Setup

### Configure your TFE Workspace

* Clone this Repo into your VCS
* Configure your TFE Variables

#### Variables Required

* `TFE_URL` - URL of the Server Instance, e.g. https://app.terraform.io
* `TFE_ORG` - The organization your workspaces are configured under
* `TFE_TOKEN` - Either a User Token, or a Team Token

#### Optional Variable

* `check_time` - How often (in minutes) the reaper bot should run to check on workspaces. The default is set to `5`.

#### Workspace Settings

For workspaces you wish to monitor with DriftBot, you must set an Environment Variable of `DRIFTBOT_ENABLED` with a value of 1.
