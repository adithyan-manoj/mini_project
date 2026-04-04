import requests
import json

# Testing on your actual running backend (Port 8000)
url = "http://127.0.0.1:8000/ai/chat"

print("🔍 DIAGNOSTIC: Testing RAG Pipeline...")

# Test Query: Using a broad question to trigger context retrieval
test_query = {"query": "Tell me about any events happening soon."}

try:
    response = requests.post(url, json=test_query, timeout=30)
    
    if response.status_code == 200:
        res_data = response.json()
        print("\n✅ PIPELINE SUCCESS!")
        print(f"🤖 AI Answer: {res_data.get('answer')[:100]}...")
        
        links = res_data.get('links', [])
        if links:
            print(f"🔗 Context Found: {len(links)} item(s) retrieved from your Database.")
            for link in links:
                print(f"   -> Found {link.get('type')}: {link.get('title')} (ID: {link.get('id')})")
        else:
            print("⚠️ No context found. (This might be because your Database is empty or the search threshold is high)")
            
    else:
        print(f"\n❌ PIPELINE FAILED: Status {response.status_code}")
        print(f"Error Detail: {response.text}")

except Exception as e:
    print(f"\n❌ CONNECTION ERROR: Could not reach backend - {e}")
