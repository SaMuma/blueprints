module "diagnostics_aks" {
  source  = "aztfmod/caf-diagnostics/azurerm"
  version = "0.1.1"

  name                            = var.waf_configuration_map.gateway_name
  resource_id                     = azurerm_application_gateway.gw.id
  log_analytics_workspace_id      = var.log_analytics_workspace.id
  diagnostics_map                 = var.diagnostics_map
  diag_object                     = var.diagnostics_settings
}

