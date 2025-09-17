output "cosmosdb_account_id" {
  description = "The ID of the Cosmos DB account. Equivalent to AWS DocumentDB cluster ARN."
  value       = azurerm_cosmosdb_account.this.id
}

output "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account. Equivalent to AWS DocumentDB cluster identifier."
  value       = azurerm_cosmosdb_account.this.name
}

output "cosmosdb_account_endpoint" {
  description = "The endpoint URL for the Cosmos DB account. Equivalent to AWS DocumentDB cluster endpoint."
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "cosmosdb_database_id" {
  description = "The ID of the MongoDB database within Cosmos DB."
  value       = azurerm_cosmosdb_mongo_database.this.id
}

output "cosmosdb_database_name" {
  description = "The name of the MongoDB database within Cosmos DB."
  value       = azurerm_cosmosdb_mongo_database.this.name
}

output "cosmosdb_nsg_id" {
  description = "The ID of the Network Security Group for Cosmos DB."
  value       = azurerm_network_security_group.this.id
}

output "cosmosdb_nsg_name" {
  description = "The name of the Network Security Group for Cosmos DB."
  value       = azurerm_network_security_group.this.name
}
