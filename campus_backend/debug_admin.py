import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

url = os.getenv("supabase_url")
key = os.getenv("supabase_key")
service_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

print(f"URL: {url}")
print(f"Key loaded: {bool(key)}")
print(f"Service Key loaded: {bool(service_key)}")

if service_key:
    supabase = create_client(url, service_key)
    try:
        users = supabase.auth.admin.list_users()
        print("Success: Admin access confirmed.")
    except Exception as e:
        print(f"Error: {e}")
else:
    print("Error: Service key not found in env.")
