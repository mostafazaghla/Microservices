variable "resource_group_name" {
  default = "pwc-aks-resource-group"
}

variable "location" {
  default = "East US"
}

variable "aks_cluster_name" {
  default = "pwc-aks-cluster"
}

variable "node_count" {
  default = 2
}

variable "node_size" {
  default = "Standard_B2s"
}
