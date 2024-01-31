
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id   = azurerm_subnet.workload.id
  zone_redundancy_enabled    = true
}


module "container_app_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_container_app_environment.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs                       = ["ContainerAppConsoleLogs", "ContainerAppSystemLogs", "AppEnvSpringAppConsoleLogs"]

}

resource "azurerm_user_assigned_identity" "github_runner" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = "mi-${var.application_name}-${var.environment_name}-${random_string.main.result}-github-runner"
}


resource "azapi_resource" "github_runner" {

  type      = "Microsoft.App/jobs@2023-05-01"
  name      = "caej-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location  = azurerm_resource_group.main.location
  parent_id = azurerm_resource_group.main.id
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.github_runner.id
    ]
  }
  body = jsonencode({
    properties = {
      configuration = {
        eventTriggerConfig = {
          parallelism            = 1
          replicaCompletionCount = 1
          scale = {
            maxExecutions   = 10
            minExecutions   = 0
            pollingInterval = 30
            rules = [
              {
                auth = [
                  {
                    secretRef        = "personal-access-token"
                    triggerParameter = "personalAccessToken"
                  }
                ]
                metadata = {
                  githubAPIURL              = "https://api.github.com"
                  owner                     = var.github_owner
                  runnerScope               = "repo"
                  repos                     = var.github_repo
                  targetWorkflowQueueLength = "1"
                }
                name = "github-runner"
                type = "github-runner"
              }
            ]
          }
        }
        /*
        manualTriggerConfig = {
          parallelism = int
          replicaCompletionCount = int
        }
        registries = [
          {
            identity          = "string"
            passwordSecretRef = "string"
            server            = "string"
            username          = "string"
          }
        ]
        */
        replicaRetryLimit = 0
        replicaTimeout    = 1800
        /*
        scheduleTriggerConfig = {
          cronExpression         = "string"
          parallelism            = int
          replicaCompletionCount = int
        }*/
        secrets = [
          {
            keyVaultUrl = "${azurerm_key_vault.main.vault_uri}secrets/${azurerm_key_vault_secret.github_token.name}"
            identity    = azurerm_user_assigned_identity.github_runner.principal_id
            name        = "personal-access-token"
          }
        ]
        triggerType = "Event"
      }
      environmentId = azurerm_container_app_environment.main.id
      template = {
        containers = [
          {
            /*
            args = [
              "string"
            ]
            command = [
              "string"
            ]*/
            env = [
              {
                name      = "GITHUB_PAT"
                secretRef = "personal-access-token"
              },
              {
                name  = "REPO_URL"
                value = "https://github.com/${var.github_owner}/${var.github_repo}"
              },
              {
                name  = "REGISTRATION_TOKEN_API_URL"
                value = "https://api.github.com/repos/${var.github_owner}/${var.github_repo}/actions/runners/registration-token"
              }
            ]
            image = "${azurerm_container_registry.main.name}.azurecr.io/${var.container_name}:latest"
            name  = "gh-${var.application_name}-${var.environment_name}-${random_string.main.result}"
            /*
            probes = [
              {
                failureThreshold = int
                httpGet = {
                  host = "string"
                  httpHeaders = [
                    {
                      name  = "string"
                      value = "string"
                    }
                  ]
                  path   = "string"
                  port   = int
                  scheme = "string"
                }
                initialDelaySeconds = int
                periodSeconds       = int
                successThreshold    = int
                tcpSocket = {
                  host = "string"
                  port = int
                }
                terminationGracePeriodSeconds = int
                timeoutSeconds                = int
                type                          = "string"
              }
            ]
            */
            resources = {
              cpu    = 2
              memory = "4Gi"
            }
            /*
            volumeMounts = [
              {
                mountPath  = "string"
                subPath    = "string"
                volumeName = "string"
              }
            ]
            */
          }
        ]
        /*
        initContainers = [
          {
            args = [
              "string"
            ]
            command = [
              "string"
            ]
            env = [
              {
                name      = "GITHUB_PAT"
                secretRef = "personal-access-token"
              },
              {
                name  = "REPO_URL"
                value = "https://github.com/$REPO_OWNER/$REPO_NAME"
              },
              {
                name  = "REGISTRATION_TOKEN_API_URL"
                value = "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runners/registration-token"
              }
            ]
            image = "string"
            name  = "string"
            resources = {
              cpu    = "2.0"
              memory = "4Gi"
            }
            volumeMounts = [
              {
                mountPath  = "string"
                subPath    = "string"
                volumeName = "string"
              }
            ]
          }
        ]
        volumes = [
          {
            mountOptions = "string"
            name         = "string"
            secrets = [
              {
                path      = "string"
                secretRef = "string"
              }
            ]
            storageName = "string"
            storageType = "string"
          }
        ]      
        workloadProfileName = "string"
      */
      }
    }
  })

}