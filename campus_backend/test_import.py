print("Phase 1: Starting imports...", flush=True)
import os
import numpy as np
print("Phase 2: Core imports done.", flush=True)
from sentence_transformers import SentenceTransformer
print("Phase 3: Transformer import done.", flush=True)
from supabase import create_client, Client
print("Phase 4: Supabase import done.", flush=True)
from dotenv import load_dotenv
print("Phase 5: Dotenv import done.", flush=True)
from groq import Groq
print("Phase 6: Groq import done.", flush=True)
load_dotenv()
print("Phase 7: Dotenv loaded.", flush=True)
print("SUCCESS: All imports fine.", flush=True)
