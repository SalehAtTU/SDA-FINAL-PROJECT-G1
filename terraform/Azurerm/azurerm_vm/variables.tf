variable "resource_group_name" {

  type = string

}

variable "location" {

  type = string

}


variable "computer_name" {

  type = string
  
}


variable "vm_name" {

  type = string

}

variable "vm_size" {
  type = string

  default = "Standard_D2s_v3"

}

variable "username" {

  type = string

  default = "azureuser"

}

variable "os_disk_caching" {

  type = string

  default = "ReadWrite"
  
}

variable "os_disk_storage_account_type" {

  type = string

  default = "Standard_LRS"

}

variable "source_image_reference_offer" {

    default = "0001-com-ubuntu-server-jammy"
  
}

variable "source_image_reference_publisher" {
   default = "Canonical"
}

variable "source_image_reference_sku" {
   default = "22_04-lts"
}

variable "source_image_reference_version" {
   default = "latest"
}

variable "public_key" {

  type = string
  
}

variable "nic_id" {

  type = string
  
}