import chromadb
import os
import json

# Connect to ChromaDB
CHROMA_DB_PATH = os.path.join(os.path.dirname(__file__), "step3_vectordb", "chroma_data")
client = chromadb.PersistentClient(path=CHROMA_DB_PATH)

# Get list of all collections
collections = client.list_collections()
if not collections:
    print("No data has been synced yet.")
    exit()

# Get the first collection (e.g. ml_notes)
first_collection = client.get_collection(collections[0].name)

# Get data (to see the first 5 chunks)
data = first_collection.get(limit=5)

print(f"\n=========================================")
print(f"Collection Name: {collections[0].name}")
print(f"Total Chunks Stored: {first_collection.count()}")
print(f"=========================================\n")

# Print data
for i in range(len(data['ids'])):
    print(f"Chunk ID: {data['ids'][i]}")
    print(f"Text: {data['documents'][i][:100]}... (truncated)")
    print(f"Metadata: {data['metadatas'][i]}")
    print("-" * 50)
