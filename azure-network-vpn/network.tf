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

  aws_networks =  [
    {
      local_gw_name         = "eks-dev-tunnel1"
      local_gateway_address = "44.231.252.235"
      local_address_space   = ["10.30.0.0/16"]
      shared_key            = "qFQ6oR4wdccL0fdwyXENGgSfsQlVyl.D"
    },
    {
      local_gw_name         = "eks-dev-tunnel2"
      local_gateway_address = "44.237.20.42"
      local_address_space   = ["10.30.0.0/16"]
      shared_key            = "pqjJ9.YRAkcGQHh4pdSlPaBhmM1FAnBq"
    },
  ]

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

#---------------------------
# Local Network Gateway
#---------------------------
resource "azurerm_local_network_gateway" "localgw" {
  count               = length(local.aws_networks)
  name                = "streamkap-${local.aws_networks[count.index].local_gw_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  gateway_address     = local.aws_networks[count.index].local_gateway_address
  address_space       = local.aws_networks[count.index].local_address_space

  tags = local.tags
}

#---------------------------------------
# Virtual Network Gateway Connection
#---------------------------------------
resource "azurerm_virtual_network_gateway_connection" "az-hub-aws" {
  count                           = length(local.aws_networks)
  name                            = "localgw-connection-${local.aws_networks[count.index].local_gw_name}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  type                            = "IPsec"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id        = azurerm_local_network_gateway.localgw[count.index].id
  express_route_circuit_id        = null
  peer_virtual_network_gateway_id = null
  shared_key                      = local.aws_networks[count.index].shared_key
  connection_protocol             = "IKEv2"

  tags = local.tags
}