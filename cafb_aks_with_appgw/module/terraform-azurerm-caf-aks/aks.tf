resource "random_string" "dns_prefix" {
    length              = 44
    upper               = false
    special             = true
    override_special    = "-"
}

locals {
    dns_prefix  = "a${random_string.dns_prefix.result}"
    aks_name    = "${var.prefix}${var.aks_map.aks_name}"
}


resource "azurerm_kubernetes_cluster" "k8s" {

    depends_on = [
        "azurerm_role_assignment.ra1",
        "azurerm_role_assignment.ra2"
    ]

    name                    = local.aks_name
    resource_group_name     = var.resource_group_name
    location                = var.location
    dns_prefix              = local.dns_prefix
    kubernetes_version      = var.aks_map.aks_version

    linux_profile {
        admin_username = var.aks_map.vm_user_name

        ssh_key {
            key_data = var.public_ssh_key_openssh
        }
    }

    addon_profile {
        http_application_routing {
            enabled = false
        }

        oms_agent {
            enabled                    = true
            log_analytics_workspace_id = var.log_analytics_workspace.id
        }
    }

    agent_pool_profile {
        name            = "pool1"
        count           = var.aks_map.aks_agent_count
        vm_size         = var.aks_map.aks_agent_vm_size
        os_type         = "Linux"
        os_disk_size_gb = var.aks_map.aks_agent_os_disk_size
        vnet_subnet_id  = var.subnet_id
        
    }

    service_principal {
        client_id     = var.service_principal_map.app_id
        client_secret = var.service_principal_map.client_secret
    }

    network_profile {
        network_plugin     = var.aks_map.aks_netPlugin
        dns_service_ip     = var.aks_map.aks_dns_service_ip
        docker_bridge_cidr = var.aks_map.aks_docker_bridge_cidr
        service_cidr       = var.aks_map.aks_service_cidr
        pod_cidr           = var.aks_map.aks_pod_cidr
    }

}