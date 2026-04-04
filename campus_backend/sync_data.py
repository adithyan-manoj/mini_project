import os
from dotenv import load_dotenv
from supabase import create_client, Client
from ai_utils import upsert_document

load_dotenv()

# Configure Supabase
supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(supabase_url, supabase_key)

def sync_all_to_ai():
    print("🚀 SYNC: Fetching all Events and Posts for AI...")
    
    try:
        # 1. Sync Events
        events = supabase.table("events").select("*").execute().data
        print(f"📊 Found {len(events)} events.")
        for e in events:
            content = f"Event: {e['title']}. Description: {e['description']}. Venue: {e['venue']}. Date: {e['event_date']}."
            metadata = {"type": "event", "id": str(e['id']), "title": e['title']}
            upsert_document(content, metadata)

        # 2. Sync Posts
        posts = supabase.table("posts").select("*").execute().data
        print(f"📊 Found {len(posts)} posts.")
        for p in posts:
            content = f"Community Post: {p['title']}. Content: {p['content']}."
            metadata = {"type": "post", "id": str(p['id']), "title": p['title']}
            upsert_document(content, metadata)
            
        print("\n✨ SYNC COMPLETE! Your Chatbot now knows everything in your database.")
        
    except Exception as e:
        print(f"❌ Sync Error: {e}")

if __name__ == "__main__":
    sync_all_to_ai()
