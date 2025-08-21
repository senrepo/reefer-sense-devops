
# Syntax Validation
az bicep build --file main.bicep

# Validate deployment
az deployment group validate --resource-group rg-dev --template-file main.bicep --parameters dev.parameters.json

# Deploy
az deployment group create  --resource-group rg-dev --template-file main.bicep  --parameters dev.parameters.json





