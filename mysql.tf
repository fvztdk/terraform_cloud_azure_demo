resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_string" "random" {
  length           = 5
  special          = false
  upper            = false
}

resource "azurerm_mysql_server" "example" {
  name                = "example-mysqlserver-${random_string.random.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login          = "mysqladminun"
  administrator_login_password = random_password.password.result

  sku_name   = "B_Gen5_1"
  storage_mb = 6120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  depends_on = [
    random_password.password,
    random_string.random
  ]
}


resource "azurerm_mysql_firewall_rule" "example" {
  name                = "block"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_server.example.name
  start_ip_address    = "8.8.8.8"
  end_ip_address      = "8.8.8.8"
  depends_on = [
    azurerm_mysql_server.example,
    azurerm_resource_group.example
  ]
}