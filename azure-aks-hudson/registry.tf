resource "azurerm_container_registry" "acr" {
  name                = var.nuon_id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_container_registry_scope_map" "acr" {
  name                    = var.nuon_id
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = azurerm_resource_group.rg.name
  actions = [
    "repositories/${var.nuon_id}/content/read",
    "repositories/${var.nuon_id}/content/write"
  ]
}

resource "random_pet" "token_name" {
  prefix    = "runner"
  separator = ""
}

resource "azurerm_container_registry_token" "runner" {
  name                    = random_pet.token_name.id
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = azurerm_resource_group.rg.name
  scope_map_id            = azurerm_container_registry_scope_map.acr.id
}

resource "azurerm_container_registry_token_password" "runner" {
  container_registry_token_id = azurerm_container_registry_token.runner.id

  password1 {}
}
