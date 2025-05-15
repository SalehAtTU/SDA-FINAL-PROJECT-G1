locals {
  prefix                  = "devops2-group1-final-project"
  location                = "uae north"
  default_node_pool_name  = "sau"

  vnet_address_space      = ["10.2.0.0/16"]
  subnet_address_prefixes = ["10.2.2.0/24"]

  sql_db = {
    username             = "auth-group1-project"
    collation            = "SQL_Latin1_General_CP1_CI_AS"
    password             = "m/2.71.0/do"
    server_version       = "12.0"
    dbsize               = 1
    zone_redundant       = false
    sql_database_name    = "${local.prefix}-db"
    sku_name             = "Basic"
    storage_account_type = "Local"
  }

  nsg_rule = {
    allow_ssh = {
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    allow_3000 = {
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  public_ips = {
    master-ip = {
      allocation_method = "Static"
    }
  }

  nics = {
    master-nic = {
      ip_configuration_name         = "master-ipconfig"
      subnet                        = "internal"
      private_ip_address_allocation = "Dynamic"
      public_ip                     = "master-ip"
    }
  }

  virtual_machine = {
    master = {
      nic = "master-nic"
    }
  }
}
