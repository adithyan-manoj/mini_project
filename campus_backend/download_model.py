from sentence_transformers import SentenceTransformer
import os

model_name = 'all-MiniLM-L6-v2'
local_path = f"./models/{model_name}"

if not os.path.exists(local_path):
    print(f"Downloading {model_name} to {local_path}...")
    try:
        model = SentenceTransformer(model_name)
        model.save(local_path)
        print("✅ Model pre-downloaded successfully.")
    except Exception as e:
        print(f"❌ Failed to download model: {e}")
else:
    print(f"✅ Model folder already exists at {local_path}")
