import requests
import os
import json
import boto3
import decimal
from botocore.exceptions import ClientError

#TFE Variables - set in the Terraform Code, which inputs them into the Lambda Function
tfeURL = os.environ["TFE_URL"]
org = os.environ["TFE_ORG"]
AtlasToken = os.environ["TFE_TOKEN"]

#Base TFE headers 
headers = {'Authorization': "Bearer " + AtlasToken, 'Content-Type' : 'application/vnd.api+json'}
getWorkspaces_URL = tfeURL + "/api/v2/organizations/" + org + "/workspaces"

def grabWorkspaceDetails(URL):
    response = json.loads((requests.get(tfeURL + URL,headers=headers)).text)
    return(response)

def queueRun(workspaceID):
    payload = {
        "data": {
            "attributes": {
                "is-destroy":False
                "message": "Run queue by DriftBot"
                },
            "type":"runs",
            "relationships": {
                "workspace": {
                    "data": {
                        "type": "workspaces",
                        "id": workspaceID
                        }
                    }
                }
            }
        }
    response = json.loads(requests.post(tfeURL + "/api/v2/runs", headers=headers, data=json.dumps(payload)).text)
    return response

def DriftDetector(json_input, context):
    getVariables_URL = tfeURL + "/api/v2/vars"
    variables = json.loads((requests.get(getVariables_URL, headers=headers)).text)
    for variable in variables['data']:
        workspaceURL = variable['relationships']['configurable']['links']['related']
        workspaceID = variable['relationships']['configurable']['data']['id']
        wsDetails = grabWorkspaceDetails(workspaceURL)
        if org.lower() == (wsDetails['data']['relationships']['organization']['data']['id']).lower():
            if variable['attributes']['key'] == "DRIFTBOT_ENABLED":
                print("Lets Do this")
                runDetails = queueRun(workspaceID)
    return {"status":"Success"}