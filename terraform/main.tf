resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "archive" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "billing_archive" {
  name                  = "billing-archive"
  storage_account_name  = azurerm_storage_account.archive.name
  container_access_type = "private"
}

resource "azurerm_cosmosdb_account" "main" {
  name                = var.cosmosdb_account_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "billing_db" {
  name                = "billing"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_sql_container" "billing_container" {
  name                  = "billing-records"
  resource_group_name   = azurerm_resource_group.main.name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.billing_db.name
  partition_key_path    = "/customerId"
  throughput            = 400
}

resource "azurerm_storage_account" "function_storage" {
  name                     = "funcstor${random_id.rand.hex}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_id" "rand" {
  byte_length = 4
}

resource "azurerm_app_service_plan" "function_plan" {
  name                = "function-app-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "archive_func" {
  name                       = "archive-billing-function"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  app_service_plan_id        = azurerm_app_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  version                    = "~4"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.function_storage.primary_connection_string
    BLOB_CONTAINER_NAME      = azurerm_storage_container.billing_archive.name
  }
}

resource "azurerm_data_factory" "billing_adf" {
  name                = "billingDataFactory"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}
