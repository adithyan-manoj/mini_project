import os
from dotenv import load_dotenv
from supabase import create_client, Client
from ai_utils import get_embedding

load_dotenv()

# Configure Supabase
supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(supabase_url, supabase_key)

def reindex_all():
    print("🚀 Starting Re-Indexing of all documents...")
    try:
        # 1. Fetch all documents
        res = supabase.table("documents").select("*").execute()
        documents = res.data
        print(f"📊 Found {len(documents)} documents to re-index.")

        for doc in documents:
            doc_id = doc['id']
            content = doc['content']
            print(f"🔄 Re-embedding Doc ID: {doc_id}...")

            # 2. Generate new embedding with the local model
            new_embedding = get_embedding(content)
            
            if new_embedding:
                # 3. Update the document with the new embedding
                supabase.table("documents").update({"embedding": new_embedding}).eq("id", doc_id).execute()
                print(f"✅ Updated: {doc_id}")
            else:
                print(f"❌ Failed to embed: {doc_id}")

        print("\n✨ RE-INDEXING COMPLETE! Your search is now compatible with the new local AI model.")
    except Exception as e:
        print(f"❌ Re-indexing Error: {e}")

if __name__ == "__main__":
    reindex_all()
