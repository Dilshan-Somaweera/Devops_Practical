variable "azure_region" {
  description = "Azure region for resources"
  default     = "East US"
}

variable "vnet_cidr" {
  description = "CIDR block for the VNet"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "my_ip" {
  description = "Your public IP address for SSH access"
  default     = "0.0.0.0/0"
}

variable "db_username" {
  description = "Database administrator username"
  default     = "wpdbadmin"  # Changed from "admin" to "wpdbadmin"
}

variable "db_password" {
  description = "Database administrator password"
  default     = "admin123$"
  sensitive   = true
}


variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}
