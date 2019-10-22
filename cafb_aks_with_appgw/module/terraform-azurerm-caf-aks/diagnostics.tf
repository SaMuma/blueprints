module "diagnostics_aks" {
  source  = "aztfmod/caf-diagnostics/azurerm"
  version = "0.1.1"

  name                            = local.aks_name
  resource_id                     = azurerm_kubernetes_cluster.k8s.id
  log_analytics_workspace_id      = var.log_analytics_workspace.id
  diagnostics_map                 = var.diagnostics_map
  diag_object                     = var.diagnostics_settings
}

