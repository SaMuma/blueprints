
module "resource_groups" {
    source  = "aztfmod/caf-resource-group/azurerm"
    version = "~>0.1.1"
  
    prefix          = var.prefix
    resource_groups = var.resource_groups
    tags            = local.tags
}

module "virtual_network" {
    source  = "aztfmod/caf-virtual-network/azurerm"
    version = "~>0.1.0"

    prefix                      = var.prefix
    virtual_network_rg          = module.resource_groups.object.networking.name
    location                    = var.resource_groups.networking.location
    networking_object           = var.networking
    tags                        = local.tags
    diagnostics_map             = var.diagnostics_map
    log_analytics_workspace     = var.log_analytics_workspace
}

# Create service principal for the AKS cluster
module "aks_service_principal" {
    source                      = "git://github.com/LaurentLesle/azure_terraform_blueprint_modules_service_principal.git?ref=v1.0"
    
    prefix                      = var.prefix
    name                        = var.identity.name
    end_date                    = var.identity.end_date
}

# Create the user assigned identity
module "user_msi" {
    source                      = "git://github.com/LaurentLesle/azure_terraform_blueprint_modules_user_identity.git?ref=v1.1"
  
    prefix                      = var.prefix
    resource_group_name         = module.resource_groups.object.identity.name
    location                    = module.resource_groups.object.identity.location
    name                        = var.identity.user_msi
}

# Generate the ssh keys
module "aks_ssh_keys" {
    source                      = "git://github.com/LaurentLesle/azure_terraform_blueprint_modules_ssh_keys.git?ref=v1.0.1"
}

module "aks_cluster" {
    source                      = "./module/terraform-azurerm-caf-aks"
    
    prefix                      = var.prefix
    location                    = var.resource_groups.aks.location
    resource_group_name         = module.resource_groups.object.aks.name
    resource_group_id           = module.resource_groups.object.aks.id
    vnet_resource_group_name    = module.resource_groups.object.networking.name
    public_ssh_key_openssh      = module.aks_ssh_keys.public_key_openssh
    service_principal_map       = module.aks_service_principal.service_principal_map
    user_msi_map                = module.user_msi.map
    virtual_network_name        = module.virtual_network.vnet_obj.name
    subnet_id                   = module.virtual_network.subnet_ids_map.aks.id
    aks_map                     = var.object
    log_analytics_workspace     = var.log_analytics_workspace
    diagnostics_map             = var.diagnostics_map
    diagnostics_settings        = var.aks_diagnostics_settings

}

module "application_gateway" {
    source                      = "./module/terraform-azurerm-caf-application-gateway"

    prefix                      = var.prefix
    resource_group_name         = module.resource_groups.object.appgateway.name
    location                    = var.resource_groups.appgateway.location
    vnet_id                     = module.virtual_network.vnet_obj.id
    waf_configuration_map       = var.waf_configuration
    internal_ip_ingress         = module.aks_cluster.nginx-ingress_loadbalancer_ip
    log_analytics_workspace     = var.log_analytics_workspace
    diagnostics_map             = var.diagnostics_map
    diagnostics_settings        = var.waf_diagnostics_settings
}


