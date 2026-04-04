import os
from dotenv import load_dotenv
from groq import Groq

load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

try:
    print("Available Groq Models:")
    models = client.models.list().data
    for m in models:
        print(f"- {m.id}")
except Exception as e:
    print(f"Error fetching models: {e}")
