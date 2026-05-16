from sentence_transformers import SentenceTransformer
import os
import sys

# Ensure UTF-8 output for emojis if we must, but let's just avoid them
# Use a simple ASCII output

model_name = 'all-MiniLM-L6-v2'
local_path = os.path.join(os.getcwd(), "models", model_name)

if not os.path.exists("./models"):
    os.makedirs("./models")

print(f"DEBUG: Starting download of model {model_name}...")
try:
    # Explicitly set cache_dir to our local path for easier management if we want to bypass default hub
    # But first just try to let it download to common cache
    model = SentenceTransformer(model_name)
    model.save(local_path)
    print(f"SUCCESS: Model saved as {local_path}")
except Exception as e:
    print(f"FAILURE: Model download failed with: {str(e)}")
    import traceback
    traceback.print_exc()
