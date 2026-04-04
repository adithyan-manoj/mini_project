import os
from supabase import create_client, Client
from dotenv import load_dotenv
from ai_utils import upsert_document

load_dotenv()

# Configure Supabase
supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(supabase_url, supabase_key)

def seed_existing_data():
    print("🚀 Starting AI Seeding for existing data...")

    # 1. Index Events
    try:
        events = supabase.table("events").select("*").execute()
        for event in events.data:
            content = f"Event: {event['title']}. Description: {event['description']}. Venue: {event['venue']}. Date: {event['event_date']}."
            metadata = {
                "type": "event",
                "id": str(event['id']),
                "title": event['title'],
                "path": "/events"
            }
            upsert_document(content, metadata)
        print(f"✅ Indexed {len(events.data)} events.")
    except Exception as e:
        print(f"❌ Error seeding events: {e}")

    # 2. Index Public Posts
    try:
        posts = supabase.table("posts").select("*").execute()
        for post in posts.data:
            content = f"Post Title: {post['title']}. Content: {post['content']}."
            metadata = {
                "type": "post",
                "id": str(post['id']),
                "title": post['title'],
                "path": "/community"
            }
            upsert_document(content, metadata)
        print(f"✅ Indexed {len(posts.data)} posts.")
    except Exception as e:
        print(f"❌ Error seeding posts: {e}")

    print("🏁 Seeding complete!")

if __name__ == "__main__":
    seed_existing_data()
