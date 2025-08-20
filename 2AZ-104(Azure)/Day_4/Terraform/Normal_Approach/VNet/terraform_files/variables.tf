# Resource Group Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-terraform-vnet-normal"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Virtual Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-terraform-normal"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# Web Subnet Variables
variable "web_subnet_name" {
  description = "Name of the web subnet"
  type        = string
  default     = "subnet-web"
}

variable "web_subnet_address_prefixes" {
  description = "Address prefixes for the web subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# App Subnet Variables
variable "app_subnet_name" {
  description = "Name of the application subnet"
  type        = string
  default     = "subnet-app"
}

variable "app_subnet_address_prefixes" {
  description = "Address prefixes for the application subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# Database Subnet Variables
variable "database_subnet_name" {
  description = "Name of the database subnet"
  type        = string
  default     = "subnet-database"
}

variable "database_subnet_address_prefixes" {
  description = "Address prefixes for the database subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

# Security Variables
variable "admin_source_address_prefix" {
  description = "Source address prefix for admin access (your public IP)"
  type        = string
  default     = "*" # Change this to your public IP for better security
}

# Optional: Add validation for variables
variable "allowed_locations" {
  description = "List of allowed Azure regions"
  type        = list(string)
  default     = ["East US", "West US", "Central US", "West Europe", "East Asia"]

  validation {
    condition     = contains(var.allowed_locations, var.location)
    error_message = "The location must be one of the allowed regions."
  }
}

variable "environment_types" {
  description = "List of allowed environment types"
  type        = list(string)
  default     = ["dev", "staging", "prod"]

  validation {
    condition     = contains(var.environment_types, var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}