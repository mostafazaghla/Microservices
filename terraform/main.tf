resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "pwc-aks"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }
}
