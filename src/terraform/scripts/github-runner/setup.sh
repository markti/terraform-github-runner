export GITHUB_PAT=""
export CONTAINER_REGISTRY_NAME="craztflabdevzgdkwdkd.azurecr.io"
export CONTAINER_IMAGE_NAME="github-runner"

az acr build \
    --registry "$CONTAINER_REGISTRY_NAME" \
    --image "$CONTAINER_IMAGE_NAME" \
    --file "Dockerfile.github" \
    "https://github.com/Azure-Samples/container-apps-ci-cd-runner-tutorial.git"

