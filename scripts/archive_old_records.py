import os
import json
import datetime
from azure.cosmos import CosmosClient, PartitionKey
from azure.storage.blob import BlobServiceClient, ContentSettings

# --- Environment Variables (or load from config/.env) ---
COSMOS_ENDPOINT = os.environ['COSMOS_ENDPOINT']
COSMOS_KEY = os.environ['COSMOS_KEY']
COSMOS_DB_NAME = os.environ['COSMOS_DB_NAME']
COSMOS_CONTAINER_NAME = os.environ['COSMOS_CONTAINER_NAME']

BLOB_CONN_STR = os.environ['BLOB_CONN_STR']
BLOB_CONTAINER_NAME = os.environ['BLOB_CONTAINER_NAME']

# --- Cosmos & Blob Clients ---
cosmos_client = CosmosClient(COSMOS_ENDPOINT, COSMOS_KEY)
db = cosmos_client.get_database_client(COSMOS_DB_NAME)
container = db.get_container_client(COSMOS_CONTAINER_NAME)

blob_service_client = BlobServiceClient.from_connection_string(BLOB_CONN_STR)
blob_container = blob_service_client.get_container_client(BLOB_CONTAINER_NAME)

# --- Archival Function ---
def archive_old_records():
    print("Starting archival process...")

    # Get cutoff date (90 days ago)
    cutoff_date = (datetime.datetime.utcnow() - datetime.timedelta(days=90)).isoformat()

    # Query Cosmos DB for old records
    query = f"SELECT * FROM c WHERE c.timestamp < '{cutoff_date}'"
    old_records = list(container.query_items(query=query, enable_cross_partition_query=True))

    print(f"Found {len(old_records)} records to archive...")

    for record in old_records:
        try:
            record_id = record['id']
            customer_id = record.get('customerId', 'unknown')
            timestamp = datetime.datetime.fromisoformat(record['timestamp'])
            year = timestamp.year
            month = str(timestamp.month).zfill(2)

            # Build blob path
            blob_path = f"{customer_id}/{year}/{month}/{record_id}.json"

            # Upload to blob
            blob_container.upload_blob(
                name=blob_path,
                data=json.dumps(record),
                overwrite=True,
                content_settings=ContentSettings(content_type='application/json')
            )

            # Delete from Cosmos DB
            container.delete_item(item=record_id, partition_key=record['customerId'])

            print(f"Archived and deleted record {record_id}")

        except Exception as e:
            print(f"Error archiving record {record.get('id', '?')}: {str(e)}")

    print("Archival process completed.")

# --- Optional Entry Point ---
if __name__ == "__main__":
    archive_old_records()
