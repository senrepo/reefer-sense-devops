# Syntax Validation
az bicep build --file main.bicep

# Validate deployment
az deployment group validate --resource-group rg-prod --template-file main.bicep --parameters prod.parameters.json

# What-if check
az deployment group what-if --resource-group rg-prod --template-file main.bicep --parameters prod.parameters.json

# Deploy
az deployment group create  --resource-group rg-prod --template-file main.bicep  --parameters prod.parameters.json