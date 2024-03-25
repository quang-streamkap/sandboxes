locals {
  // we create a network with two address spaces - one for node pool subnets and one for services, gateways etc.
  address_spaces = ["172.29.0.0/24"]
  // node pool subnets
  subnet_cidrs = ["172.29.0.0/24"]
  subnet_names = ["streamkap",]

  // app and services
  service_cidr = "10.0.0.0/24"
  dns_service_ip = "10.0.0.10"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  address_spaces      = local.address_spaces

  // we create three subnets - one for the nodes, one for ingresses and one for pods
  subnet_prefixes     = local.subnet_cidrs
  subnet_names        = local.subnet_names

  subnet_service_endpoints = {
    "streamkap" : ["Microsoft.Storage"]
  }
  use_for_each = true
  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  depends_on = [azurerm_resource_group.rg]
}
