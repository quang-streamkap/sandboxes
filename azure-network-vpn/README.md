# Azure AKS

Standard Azure sandbox that provisions the following:

* VPN
* AKS Cluster

## Usage

To use this in your BYOC app, please use the `azure-aks` runner type:

```toml
version = "v1"

[runner]
runner_type = "azure-aks"

[sandbox]
terraform_version = "1.5.4"
[sandbox.public_repo]
directory = "azure-aks"
repo = "nuonco/sandboxes"
branch = "main"
```

## Testing

This sandbox can be tested outside of `nuon` by following these steps:

1. Ensure you have an Azure account setup and `az` installed
1. [Create Service Principal Credentials](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?tabs=bash#create-a-service-principal)
1. Create a `terraform.tfvars` with the correct variable inputs
