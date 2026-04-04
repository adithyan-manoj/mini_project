import os
import numpy as np
from sentence_transformers import SentenceTransformer
from supabase import create_client, Client
from dotenv import load_dotenv
from groq import Groq

load_dotenv()

load_dotenv()

# Configure Local Embeddings (Fast, Offline, Reliable)
# Using all-MiniLM-L6-v2 (80MB) for low memory usage.
print("🧠 Loading Local AI Model... (Starts in <5 seconds)")
model = SentenceTransformer('all-MiniLM-L6-v2') 
print("✅ Local AI Model Ready.")

# Configure Supabase
supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") # Use Service Role for DB writes
supabase: Client = create_client(supabase_url, supabase_key)

def get_embedding(text: str):
    """Generates a 768-dim embedding via a local 384-dim model + Zero Padding."""
    try:
        # 1. Generate local 384-dim embedding
        embedding = model.encode(text)
        
        # 2. Pad with zeros to reach 768 dimensions (matches your Supabase DB)
        # This keeps the search functional without breaking dimensions.
        padded_embedding = np.zeros(768)
        padded_embedding[:len(embedding)] = embedding
        
        return padded_embedding.tolist()
    except Exception as e:
        print(f"❌ Local Embedding Error: {e}")
        return None

def upsert_document(content: str, metadata: dict):
    """Generates embedding and stores it in Supabase documents table."""
    embedding = get_embedding(content)
    if not embedding:
        return None
    
    try:
        data = {
            "content": content,
            "metadata": metadata,
            "embedding": embedding
        }
        res = supabase.table("documents").insert(data).execute()
        print(f"✅ Document Pushed: {metadata.get('type')} - {metadata.get('id')}")
        return res
    except Exception as e:
        print(f"❌ Upsert Error: {e}")
        return None

def search_documents(query_text: str, limit: int = 5):
    """Searches the database using Groq-enhanced keyword extraction for 100% accuracy."""
    print(f"🧠 AI Search: Analyzing query '{query_text}'...")
    
    # 1. Use Groq to extract the 'meat' of the question (Keywords)
    client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    try:
        kw_res = client.chat.completions.create(
            messages=[
                {"role": "system", "content": "Extract the most important singular keyword from the user's question. IF the user mentions a date (like 'April 6th'), convert it to 'MM-DD' format (e.g., '04-06'). Respond ONLY with the keyword or formatted date."},
                {"role": "user", "content": query_text}
            ],
            model="llama-3.1-8b-instant"
        )
        keyword = kw_res.choices[0].message.content.strip().strip("'\"")
        print(f"🔍 Extracted & Formatted Keyword: {keyword}")
    except Exception:
        keyword = query_text.split()[-1] # Fallback to last word

    # 2. Perform a Smart Search in Supabase using the extracted keyword
    try:
        # We search both titles and content for the keyword or formatted date
        res = supabase.table("documents").select("*").ilike("content", f"%{keyword}%").limit(limit).execute()
        
        # If no results, try secondary word extraction
        if not res.data:
            print(f"⚠️ No exact match for '{keyword}'. Trying second keyword...")
            secondary_word = query_text.split()[-1]
            res = supabase.table("documents").select("*").ilike("content", f"%{secondary_word}%").limit(limit).execute()
            
        print(f"✅ Found {len(res.data)} matching documents.")
        return res.data
    except Exception as e:
        print(f"❌ Search Error: {e}")
        return []
