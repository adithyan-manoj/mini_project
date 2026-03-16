from supabase import create_client
url = "https://lynzclilcsykpakjezuv.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bnpjbGlsY3N5a3Bha2plenV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MjgxMzUsImV4cCI6MjA4NzUwNDEzNX0.DmjpHqrSu4WffjYCO2O-yK7sJMHonqkAC5g1Z9quQm4"
supabase = create_client(url, key)
try:
    res = supabase.table("post_likes").select("*").limit(1).execute()
    print("post_likes works:", res)
except Exception as e:
    print("post_likes error:", e)

try:
    res = supabase.table("likes").select("*").limit(1).execute()
    print("likes works:", res)
except Exception as e:
    print("likes error:", e)

try:
    res = supabase.table("post_user_likes").select("*").limit(1).execute()
    print("post_user_likes works:", res)
except Exception as e:
    print("post_user_likes error:", e)
