
resource "azurerm_container_registry" "main" {
  name                          = "cr${var.application_name}${var.environment_name}${random_string.main.result}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  sku                           = "Premium"
  zone_redundancy_enabled       = true
  admin_enabled                 = true
  public_network_access_enabled = true

}