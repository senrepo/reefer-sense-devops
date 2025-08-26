# Variables
$rgName = "rg-dev"

Write-Host "Cleaning up all resources in resource group: $rgName" -ForegroundColor Cyan

# 1. Delete Container Apps first
Write-Host "Step 1: Deleting Container Apps (if any)..." -ForegroundColor Yellow
$containerApps = az containerapp list --resource-group $rgName --query "[].name" -o tsv
foreach ($ca in $containerApps) {
    az containerapp delete --name $ca --resource-group $rgName --yes
    Write-Host "Deleted Container App: $ca"
}

# 2. Delete Container App Environments
Write-Host "Step 2: Deleting Container App Environments (if any)..." -ForegroundColor Yellow
$environments = az containerapp env list --resource-group $rgName --query "[].name" -o tsv
foreach ($env in $environments) {
    az containerapp env delete --name $env --resource-group $rgName --yes
    Write-Host "Deleted Container App Environment: $env"
}

# 3. Delete Private Endpoints and NICs
Write-Host "Step 3: Deleting private endpoints and NICs (if any)..." -ForegroundColor Yellow
$privateEndpoints = az network private-endpoint list --resource-group $rgName --query "[].name" -o tsv
foreach ($pe in $privateEndpoints) {
    az network private-endpoint delete --name $pe --resource-group $rgName --yes
    Write-Host "Deleted private endpoint: $pe"
}

$nicList = az network nic list --resource-group $rgName --query "[].name" -o tsv
foreach ($nic in $nicList) {
    az network nic delete --name $nic --resource-group $rgName
    Write-Host "Deleted NIC: $nic"
}

# 4. Detach NSGs/Route Tables from subnets
Write-Host "Step 4: Detaching NSGs/Route Tables from subnets..." -ForegroundColor Yellow
$vnets = az network vnet list --resource-group $rgName --query "[].name" -o tsv
foreach ($vnet in $vnets) {
    $subnets = az network vnet subnet list --resource-group $rgName --vnet-name $vnet --query "[].name" -o tsv 2>$null
    foreach ($subnet in $subnets) {
        az network vnet subnet update `
            --resource-group $rgName `
            --vnet-name $vnet `
            --name $subnet `
            --network-security-group "" `
            --route-table "" | Out-Null
        Write-Host "Detached NSG/Route table from subnet: $subnet in VNet: $vnet"
    }

    # Delete subnets
    foreach ($subnet in $subnets) {
        az network vnet subnet delete --resource-group $rgName --vnet-name $vnet --name $subnet 2>$null
        Write-Host "Deleted subnet: $subnet from VNet: $vnet"
    }
}

# 5. Delete VNets
Write-Host "Step 5: Deleting VNets..." -ForegroundColor Yellow
foreach ($vnet in $vnets) {
    az network vnet delete --name $vnet --resource-group $rgName
    Write-Host "Deleted VNet: $vnet"
}

# 6. Delete all remaining resources in RG
Write-Host "Step 6: Deleting remaining resources..." -ForegroundColor Yellow
$resources = az resource list --resource-group $rgName --query "[].id" -o tsv
foreach ($res in $resources) {
    az resource delete --ids $res --verbose
    Write-Host "Deleted resource: $res"
}

Write-Host "✅ Cleanup complete for resource group: $rgName" -ForegroundColor Green
