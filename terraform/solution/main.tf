

# generate an SSH key for your VMs
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "rg" {
  source   = "../Azurerm/azurerm_resource_group"
  name     = "${local.prefix}-rg"
  location = local.location
}

module "vnet" {
  source              = "../Azurerm/azurerm_virtual_network"
  name                = "${local.prefix}-vnet"
  location            = module.rg.resource_group.location
  resource_group_name = module.rg.resource_group.name
  address_space       = local.vnet_address_space
}

module "subnet" {
  source              = "../Azurerm/azurerm_subnets"
  name                = "internal"
  vnet_name           = module.vnet.virtual_network.name
  resource_group_name = module.rg.resource_group.name
  address_prefixes    = local.subnet_address_prefixes
}

module "aks" {
  source                   = "../Azurerm/azurerm_aks"
  name                     = "${local.prefix}-aks"
  resource_group_name      = module.rg.resource_group.name
  location                 = "uae north"
  dns_prefix               = "${local.prefix}-dns"
  vnet_subnet_id           = module.subnet.subnet.id
  identity_type            = "SystemAssigned"
  node_resource_group_name = "${local.prefix}-aks"
  default_node_pool_name   = local.default_node_pool_name
}

module "sql" {
  source               = "../Azurerm/azurerm_sql_db"
  collation            = local.sql_db.collation
  resource_group_name  = module.rg.resource_group.name
  location             = module.rg.resource_group.location
  username             = local.sql_db.username
  password             = local.sql_db.password
  server_name          = "${local.prefix}-sql"
  server_version       = local.sql_db.server_version
  dbsize               = local.sql_db.dbsize
  zone_redundant       = local.sql_db.zone_redundant
  sql_database_name    = local.sql_db.sql_database_name
  sku_name             = local.sql_db.sku_name
  storage_account_type = local.sql_db.storage_account_type
}

module "mssql_virtual_network_rule" {
  source    = "../Azurerm/azurerm_mssql_virtual_network_rule"
  name      = "${local.prefix}-mvnr"
  server_id = module.sql.sql_server.id
  subnet_id = module.subnet.subnet.id
}

module "nsg" {
  source              = "../Azurerm/azurerm_nsg"
  nsg_name            = "${local.prefix}-nsg"
  resource_group_name = module.rg.resource_group.name
  location            = module.rg.resource_group.location
}

module "nsg_rule" {
  source                      = "../Azurerm/azurerm_nsg_rule"
  for_each                    = local.nsg_rule
  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = module.rg.resource_group.name
  network_security_group_name = module.nsg.network_security_group.name
}

module "public_ip" {
  for_each               = local.public_ips
  source                 = "../Azurerm/azurerm_public_ip"
  sku                    = "Basic"
  resource_group_name    = module.rg.resource_group.name
  location               = module.rg.resource_group.location
  ip_allocation_method   = each.value.allocation_method
  public_ip_address_name = each.key
}


module "nics" {
  for_each                   = local.nics
  source                     = "../Azurerm/azurerm_nic"
  resource_group_name        = module.rg.resource_group.name
  location                   = module.rg.resource_group.location
  ip_configuration_name      = each.value.ip_configuration_name
  nic_name                   = each.key
  subnet_id                  = module.subnet.subnet.id
  network_security_group_id  = module.nsg.network_security_group.id
  public_ip_address_id       = module.public_ip[each.value.public_ip].public_ip.id
}

module "virtual_machine" {
  for_each            = local.virtual_machine
  source              = "../Azurerm/azurerm_vm"
  vm_name             = "${local.prefix}-${each.key}"
  resource_group_name = module.rg.resource_group.name
  location            = module.rg.resource_group.location
  computer_name       = each.key
  vm_size             = "Standard_D2s_v3"
  username            = "azureuser"
  nic_id              = module.nics[each.value.nic].nic.id
  public_key          = tls_private_key.ssh_key.public_key_openssh

  # these two often have defaults in the module, but if yours require them:
  os_disk_caching                 = "ReadWrite"
  os_disk_storage_account_type   = "Standard_LRS"

  source_image_reference_publisher = "Canonical"
  source_image_reference_offer     = "UbuntuServer"
  source_image_reference_sku       = "18.04-LTS"
  source_image_reference_version   = "latest"
}
