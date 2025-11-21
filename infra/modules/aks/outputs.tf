output "aks_id" { value = azurerm_kubernetes_cluster.aks.id }
output "host" { value = azurerm_kubernetes_cluster.aks.kube_config.0.host }
output "client_certificate" { value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate }
output "client_key" { value = azurerm_kubernetes_cluster.aks.kube_config.0.client_key }
output "cluster_ca_certificate" { value = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate }
output "aks_name" { value = azurerm_kubernetes_cluster.aks.name }

# --- NUEVO OUTPUT PARA LA IDENTIDAD ---
output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
