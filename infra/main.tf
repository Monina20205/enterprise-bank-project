terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host                   = module.aks_cluster.host
    client_certificate     = base64decode(module.aks_cluster.client_certificate)
    client_key             = base64decode(module.aks_cluster.client_key)
    cluster_ca_certificate = base64decode(module.aks_cluster.cluster_ca_certificate)
  }
}

variable "env" {}
variable "node_count" {}
variable "project_name" {
  default = "enterprisebank"
}

# 1. Container Registry Global
resource "azurerm_resource_group" "rg_global" {
  name     = "rg-${var.project_name}-global"
  location = "eastus2"
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project_name}global${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg_global.name
  location            = azurerm_resource_group.rg_global.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# 2. Llamada al Módulo AKS
module "aks_cluster" {
  source       = "./modules/aks"
  env          = var.env
  project_name = var.project_name
  location     = "eastus2"
  node_count   = var.node_count
  acr_id       = ""
}

# 3. Asignación de Roles (RESOLUCIÓN DEL ERROR)
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = module.aks_cluster.kubelet_object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Outputs Finales
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  value = module.aks_cluster.aks_name
}
