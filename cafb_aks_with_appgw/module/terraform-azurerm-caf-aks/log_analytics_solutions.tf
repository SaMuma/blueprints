resource "azurerm_log_analytics_solution" "la" {
  solution_name         = "ContainerInsights"
  location              = var.log_analytics_workspace.location
  resource_group_name   = var.log_analytics_workspace.resource_group_name
  workspace_resource_id = var.log_analytics_workspace.id
  workspace_name        = var.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}