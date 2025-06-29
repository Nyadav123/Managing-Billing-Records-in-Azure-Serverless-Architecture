async function getBillingRecord(id) {
    let record = await cosmosDb.get(id);
    if (!record) {
        const path = deriveBlobPath(id);
        record = await blobStorage.get(path);
    }
    return record;
}
