terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
    helm    = { source = "hashicorp/helm" }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.env}"
  location = var.location
  tags = { Environment = var.env }
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-aks-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.project_name}-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${var.env}"
  sku_tier            = var.env == "prod" ? "Standard" : "Free"

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = "Standard_B2s"
    enable_auto_scaling = var.env == "prod" ? true : false
    min_count           = var.env == "prod" ? 1 : null
    max_count           = var.env == "prod" ? 5 : null
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

# --- ELIMINADO EL ROLE ASSIGNMENT Y LA VARIABLE ACR_ID ---

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-basic"
  create_namespace = true
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }
}
