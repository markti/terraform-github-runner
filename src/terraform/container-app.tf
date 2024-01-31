
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id   = azurerm_subnet.workload.id
  zone_redundancy_enabled    = true
}
