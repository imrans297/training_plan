# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# Virtual Network Outputs
output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

output "vnet_location" {
  description = "Location of the virtual network"
  value       = azurerm_virtual_network.main.location
}

# Subnet Outputs
output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.web.id
}

output "web_subnet_name" {
  description = "Name of the web subnet"
  value       = azurerm_subnet.web.name
}

output "web_subnet_address_prefixes" {
  description = "Address prefixes of the web subnet"
  value       = azurerm_subnet.web.address_prefixes
}

output "app_subnet_id" {
  description = "ID of the application subnet"
  value       = azurerm_subnet.app.id
}

output "app_subnet_name" {
  description = "Name of the application subnet"
  value       = azurerm_subnet.app.name
}

output "app_subnet_address_prefixes" {
  description = "Address prefixes of the application subnet"
  value       = azurerm_subnet.app.address_prefixes
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.database.id
}

output "database_subnet_name" {
  description = "Name of the database subnet"
  value       = azurerm_subnet.database.name
}

output "database_subnet_address_prefixes" {
  description = "Address prefixes of the database subnet"
  value       = azurerm_subnet.database.address_prefixes
}

# Network Security Group Outputs
output "web_nsg_id" {
  description = "ID of the web network security group"
  value       = azurerm_network_security_group.web.id
}

output "web_nsg_name" {
  description = "Name of the web network security group"
  value       = azurerm_network_security_group.web.name
}

output "app_nsg_id" {
  description = "ID of the application network security group"
  value       = azurerm_network_security_group.app.id
}

output "app_nsg_name" {
  description = "Name of the application network security group"
  value       = azurerm_network_security_group.app.name
}

output "database_nsg_id" {
  description = "ID of the database network security group"
  value       = azurerm_network_security_group.database.id
}

output "database_nsg_name" {
  description = "Name of the database network security group"
  value       = azurerm_network_security_group.database.name
}

# Summary Output for Easy Reference
output "network_summary" {
  description = "Summary of the created network infrastructure"
  value = {
    resource_group = {
      name     = azurerm_resource_group.main.name
      location = azurerm_resource_group.main.location
    }
    virtual_network = {
      name          = azurerm_virtual_network.main.name
      address_space = azurerm_virtual_network.main.address_space
    }
    subnets = {
      web = {
        name             = azurerm_subnet.web.name
        address_prefixes = azurerm_subnet.web.address_prefixes
        nsg_name         = azurerm_network_security_group.web.name
      }
      app = {
        name             = azurerm_subnet.app.name
        address_prefixes = azurerm_subnet.app.address_prefixes
        nsg_name         = azurerm_network_security_group.app.name
      }
      database = {
        name             = azurerm_subnet.database.name
        address_prefixes = azurerm_subnet.database.address_prefixes
        nsg_name         = azurerm_network_security_group.database.name
      }
    }
  }
}