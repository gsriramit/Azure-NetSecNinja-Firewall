#!/bin/bash

#install JQ to be able to edit the ARM params values from script
# apt install jq

# Declare the variables
RG_LOCATION='eastus2'
RG_NETWORK_NAME='rg-netsecninja'
RG_SECOPS_NAME='rg-secops'
SUBSCRIPTION_ID="695471ea-1fc3-42ee-a854-eab6c3009516"
TENANT_ID="d787514b-d3f2-45ff-9bf1-971fb473fc85"
DEPLOYMENT_NAME="NetSecNinja-FirewallTesting"
DIAGNOSTICS_WORKSPACE_NAME="la-sentinel-workspace"

# Login to the account and set the target subscription
az login
az account set -s "${SUBSCRIPTION_ID}"

# Create the resource groups. In an enterprise setup, the resources would be split differently.
az group create -n $RG_NETWORK_NAME -l $RG_LOCATION
az group create -n $RG_SECOPS_NAME -l $RG_LOCATION

# Log-analytics workspace is a prerequisite for the following deployment
# this can be included in the arm template as well
az monitor log-analytics workspace create -g $RG_SECOPS_NAME -n $DIAGNOSTICS_WORKSPACE_NAME

# Onboard the workspace to sentinel. This way the DDOS, WAF and Azure Firewall Logs can be examined
# using Sentinel rules. SOAR can be done through the playbooks (available out of the box)

# Microsoft Sentinel pricing details
# https://azure.microsoft.com/en-us/pricing/details/microsoft-sentinel/

# Deploy the minimum required components for the execution of the Firewall use cases
# Navigate to the DeploymentTemplates directory before executing the following command
az deployment group create -g $RG_NETWORK_NAME -n $DEPLOYMENT_NAME -f LabEnvironmentDeployment/AzNetSecdeploy.json -p LabEnvironmentDeployment/AzNetSecdeploy.parameters.json

# Deallocate and generalize the VM that was built during the WAF labs. This needs to be created inside the Spoke-1 network in this setup
az vm deallocate --resource-group 'vm-vas-dev01_group' --name 'vm-vas-dev01'

az vm generalize --resource-group 'vm-vas-dev01_group' --name 'vm-vas-dev01'