resource "azurerm_role_assignment" "ra1" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = var.service_principal_map.object_id
}

resource "azurerm_role_assignment" "ra2" {
  scope                = var.user_msi_map.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.service_principal_map.object_id
}
