import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

# Check for Gemini key
key = os.getenv("GEMINI_API_KEY")
if not key:
    # Check if they updated it to something else or if it's missing
    print("❌ No GEMINI_API_KEY found in .env")
    exit(1)

genai.configure(api_key=key)

try:
    print("Testing Gemini Embeddings...")
    result = genai.embed_content(
        model="models/gemini-embedding-001",
        content="Testing embedding functionality.",
        task_type="retrieval_document"
    )
    print("✅ Embeddings working!")
    print(f"Dimension: {len(result['embedding'])}")
except Exception as e:
    print(f"❌ Embeddings failed: {e}")
