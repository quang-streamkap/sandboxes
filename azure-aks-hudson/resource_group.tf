resource "azurerm_resource_group" "rg" {
  location = var.location
  name = var.nuon_id
}
