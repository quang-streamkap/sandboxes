locals {
  // we create a network with two address spaces - one for node pool subnets and one for services, gateways etc.
  address_spaces = ["172.29.0.0/23"]
  // node pool subnets
  subnet_cidrs = ["172.29.0.0/24", "172.29.1.0/24"]
  subnet_names = ["streamkap", "GatewaySubnet"]

  // app and services
  service_cidr = "10.0.0.0/24"
  dns_service_ip = "10.0.0.10"
  name_prefix = "streamkap"
  tags = merge(var.tags,{
    environment = "dev"
    costcenter  = "it"
  })
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  address_spaces      = local.address_spaces

  vnet_name = "${local.name_prefix}-vnet"

  // we create three subnets - one for the nodes, one for ingresses and one for pods
  subnet_prefixes     = local.subnet_cidrs
  subnet_names        = local.subnet_names

  subnet_service_endpoints = {
    "streamkap" : ["Microsoft.Storage"]
  }
  use_for_each = true
  tags = local.tags

  depends_on = [azurerm_resource_group.rg]
}


data "azurerm_subnet" "snet" {
  name                 = "GatewaySubnet"
  virtual_network_name = module.network.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name

  depends_on = [ module.network ]
}

#---------------------------------------------
# Public IP for Virtual Network Gateway
#---------------------------------------------
resource "azurerm_public_ip" "pip_gw" {
  name                = lower("${local.name_prefix}-${azurerm_resource_group.rg.location}-gw-pip")
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = local.tags
}

#-------------------------------
# Virtual Network Gateway 
#-------------------------------
resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = lower("${local.name_prefix}-${azurerm_resource_group.rg.location}-gw-pip")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.snet.id
  }


  tags = local.tags

  depends_on = [module.network]
}