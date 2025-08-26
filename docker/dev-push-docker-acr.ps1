#login azure
#az login

#verify subscription
#az account show --output table

#check ACR exists
#az acr list -o table

#login ACR
az acr login --name acrReeferDev

#optional login using acr login password (refer ACR -> settings -> Access Keys)
#docker login acrreeferdev.azurecr.io -u acrreeferdev -p <password>

# Define version number as a variable
$version = "v2"

# Tag existing images
docker tag iotgateway:dev acrreeferdev.azurecr.io/iotgateway:$version
#docker tag iotdataprocessor:dev acrreeferdev.azurecr.io/iotdataprocessor:$version
#docker tag iottelegramsimulator:dev acrreeferdev.azurecr.io/iottelegramsimulator:$version

# Push the images to ACR
docker push acrreeferdev.azurecr.io/iotgateway:$version
#docker push acrreeferdev.azurecr.io/iotdataprocessor:$version
#docker push acrreeferdev.azurecr.io/iottelegramsimulator:$version

# $version = "v1"
# $images = @("iotgateway","iotdataprocessor","iottelegramsimulator")

# foreach ($img in $images) {
#     docker tag "$($img):dev" "acrreeferdev.azurecr.io/$($img):$version"
#     docker push "acrreeferdev.azurecr.io/$($img):$version"
# }
