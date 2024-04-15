output "runner" {
  value = {}
}

output "vpn" {
  value = {
    name = module.network.vnet_name
    subnet_ids = module.network.vnet_subnets
  }
}

output "acr" {
  value = {
    id = azurerm_container_registry.acr.id
    login_server = azurerm_container_registry.acr.login_server
    token_id = azurerm_container_registry_token.runner.id
    password = nonsensitive(azurerm_container_registry_token_password.runner.password1[0].value)
  }
}

output "cluster" {
  value = {
    "id" = module.aks.aks_id
    "name" = module.aks.aks_name
    "client_certificate" = nonsensitive(module.aks.client_certificate)
    "client_key" = nonsensitive(module.aks.client_key)
    "cluster_ca_certificate" = nonsensitive(module.aks.cluster_ca_certificate)
    "cluster_fqdn" = module.aks.cluster_fqdn
    "oidc_issuer_url" = module.aks.oidc_issuer_url
    "location" = module.aks.location
    "kube_config_raw" = nonsensitive(module.aks.kube_config_raw)
    "kube_admin_config_raw" = nonsensitive(module.aks.kube_admin_config_raw)
  }
}
