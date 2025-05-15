terraform {
  backend "azurerm" {
    resource_group_name  = "devops2-group1-storage-rg"
    storage_account_name = "devops2group1tfstate"
    container_name       = "tfstate"
    key                  = "3-tier-K8s-app/terraform.tfstate"
  }
}
