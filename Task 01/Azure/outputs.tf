output "wordpress_public_ip" {
  description = "Public IP address of the WordPress server"
  value       = azurerm_public_ip.wordpress.ip_address
}

output "mysql_fqdn" {
  description = "FQDN of the MySQL server"
  value       = azurerm_mysql_flexible_server.wordpress.fqdn
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the WordPress server"
  value       = "ssh azureuser@${azurerm_public_ip.wordpress.ip_address}"
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.wordpress.name
}

output "wordpress_url" {
  description = "URL to access WordPress (after setup)"
  value       = "http://${azurerm_public_ip.wordpress.ip_address}"
}