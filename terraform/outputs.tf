output "function_app_url" {
  value = azurerm_function_app.archive_func.default_hostname
}

output "cosmosdb_endpoint" {
  value = azurerm_cosmosdb_account.main.endpoint
}

output "blob_container_url" {
  value = azurerm_storage_account.archive.primary_blob_endpoint
}
