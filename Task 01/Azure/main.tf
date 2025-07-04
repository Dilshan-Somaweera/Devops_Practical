# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "wordpress" {
  name     = "wordpress-rg-${random_string.suffix.result}"
  location = var.azure_region

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "wordpress" {
  name                = "wordpress-vnet-${random_string.suffix.result}"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }
}

# Public Subnet
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.wordpress.name
  virtual_network_name = azurerm_virtual_network.wordpress.name
  address_prefixes     = [var.public_subnet_cidr]

  depends_on = [azurerm_virtual_network.wordpress]
}

# Private Subnet for Database
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.wordpress.name
  virtual_network_name = azurerm_virtual_network.wordpress.name
  address_prefixes     = [var.private_subnet_cidr]
  
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  depends_on = [azurerm_virtual_network.wordpress]
}

# Network Security Group for Web Server
resource "azurerm_network_security_group" "web" {
  name                = "wordpress-web-nsg-${random_string.suffix.result}"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }
}

# Public IP
resource "azurerm_public_ip" "wordpress" {
  name                = "wordpress-pip-${random_string.suffix.result}"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }
}

# Network Interface
resource "azurerm_network_interface" "wordpress" {
  name                = "wordpress-nic-${random_string.suffix.result}"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wordpress.id
  }

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }

  depends_on = [azurerm_subnet.public, azurerm_public_ip.wordpress]
}

# Network Interface Security Group Association
resource "azurerm_network_interface_security_group_association" "wordpress" {
  network_interface_id      = azurerm_network_interface.wordpress.id
  network_security_group_id = azurerm_network_security_group.web.id

  depends_on = [
    azurerm_network_interface.wordpress,
    azurerm_network_security_group.web
  ]
}

# Private DNS Zone for MySQL
resource "azurerm_private_dns_zone" "mysql" {
  name                = "wordpress-${random_string.suffix.result}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.wordpress.name

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }
}

# Private DNS Zone Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-vnet-link-${random_string.suffix.result}"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.wordpress.id
  resource_group_name   = azurerm_resource_group.wordpress.name

  depends_on = [
    azurerm_private_dns_zone.mysql,
    azurerm_virtual_network.wordpress
  ]
}

# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "wordpress" {
  name                   = "wordpress-mysql-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.wordpress.name
  location               = azurerm_resource_group.wordpress.location
  administrator_login    = var.db_username
  administrator_password = var.db_password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.private.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id
  sku_name               = "B_Standard_B1ms"
  version                = "5.7"

  storage {
    size_gb = 20
  }

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.mysql,
    azurerm_subnet.private
  ]
}

# MySQL Database
resource "azurerm_mysql_flexible_database" "wordpress" {
  name                = "wordpress"
  resource_group_name = azurerm_resource_group.wordpress.name
  server_name         = azurerm_mysql_flexible_server.wordpress.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  depends_on = [azurerm_mysql_flexible_server.wordpress]
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "wordpress" {
  name                = "wordpress-vm-${random_string.suffix.result}"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.wordpress.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = "Development"
    Project     = "WordPress"
  }

  depends_on = [
    azurerm_network_interface_security_group_association.wordpress,
    azurerm_mysql_flexible_server.wordpress
  ]
}