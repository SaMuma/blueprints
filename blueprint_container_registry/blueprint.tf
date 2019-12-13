resource "azurerm_resource_group" "rg" {
  name      = var.acr_object.resource_group.name
  location  = var.acr_object.resource_group.location
  tags      = local.tags
}


module "container_registry" {
  source = "../../modules/terraform-azurerm-caf-container-registry"

  name                = var.acr_object.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix              = var.prefix
  tags                = local.tags
  admin_enabled       = true
  sku                 = var.acr_object.sku
  
}