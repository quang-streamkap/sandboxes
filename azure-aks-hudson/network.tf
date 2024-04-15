locals {
  // we create a network with two address spaces - one for node pool subnets and one for services, gateways etc.
  address_spaces = ["10.0.0.0/16", "10.2.0.0/16"]
  // node pool subnets
  subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names = ["a", "b", "c"]

  // app and services
  appgw_cidr = "10.2.0.0/24"
  service_cidr = "10.2.1.0/24"
  dns_service_ip = "10.2.1.10"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  address_spaces      = local.address_spaces

  // we create three subnets - one for the nodes, one for ingresses and one for pods
  subnet_prefixes     = local.subnet_cidrs
  subnet_names        = local.subnet_names

  subnet_service_endpoints = {
    "subnet1" : ["Microsoft.Sql"],
    "subnet2" : ["Microsoft.Sql"],
    "subnet3" : ["Microsoft.Sql"]
  }
  use_for_each = true
  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  depends_on = [azurerm_resource_group.rg]
}

#resource "azurerm_subnet" "appgw" {
  #address_prefixes     = [local.appgw_cidr]
  #name                 = "${var.nuon_id}-gw"
  #resource_group_name = azurerm_resource_group.rg.name
  #virtual_network_name = module.network.vnet_name
#}
