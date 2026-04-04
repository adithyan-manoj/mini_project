import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

s = create_client(os.getenv("supabase_url"), os.getenv("SUPABASE_SERVICE_ROLE_KEY"))

try:
    events = s.table("events").select("*").execute().data
    print(f"📊 SYSTEM AUDIT: Found {len(events)} Events.")
    for ev in events:
        print(f"   -> Event: '{ev['title']}' on {ev['event_date']}")

    docs = s.table("documents").select("*").execute().data
    print(f"\n📊 AI Knowledge Base: Found {len(docs)} documents.")
    # Check if 'April' or '04-06' is in any document
    april_docs = [d for d in docs if 'April' in d['content'] or '04-06' in d['content']]
    print(f"   -> Knowledge containing 'April' or '04-06': {len(april_docs)}")
    for d in april_docs:
        print(f"      - '{d['content'][:80]}...'")

except Exception as e:
    print(f"❌ Audit Error: {e}")
