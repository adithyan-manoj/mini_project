import os
from dotenv import load_dotenv
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
from supabase import create_client, Client

app = FastAPI()

cred = credentials.Certificate("D:\Flutter study\mini project\campus_backend\serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

#supabase
load_dotenv()

supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("supabase_key")
# supabase_url = "https://lynzclilcsykpakjezuv.supabase.co"
# supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bnpjbGlsY3N5a3Bha2plenV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MjgxMzUsImV4cCI6MjA4NzUwNDEzNX0.DmjpHqrSu4WffjYCO2O-yK7sJMHonqkAC5g1Z9quQm4"


supabase: Client = create_client(supabase_url, supabase_key)


class EtLabCredentials(BaseModel):
    username:str
    password:str

ETLAB_URL = "https://sctce.etlab.in/user/login"

@app.post("/login")
async def login_to_etlab(data: EtLabCredentials):
    session = requests.Session()

    payload = {
        "LoginForm[username]": data.username,
        "LoginForm[password]": data.password,
        "yt0": "Login" 
    }

    try:
        # 3. The Robot tries to log in
        response = session.post(ETLAB_URL, data=payload, timeout=10)

        # 4. Check if we got in
        # Usually, if login is successful, the URL changes to /dashboard or /home
        if response.status_code == 200 and "Dashboard" in response.text:
            login_ref = db.collection("login_logs").document()
            login_ref.set(
                {
                    "student_id": data.username,
                    "login_time": datetime.now(),
                    "status": "success"
                }
            )
            return {"status": "success", "message": "Authenticated with ETLAB"}
        else:
            raise HTTPException(status_code=401, detail="Invalid ETLAB credentials")

    except Exception as e:
        raise HTTPException(status_code=500, detail="ETLAB Server is down")
    
@app.get("/admin/logs")
async def get_all_logs():
    try:
        logs_ref = db.collection("login_logs")

        docs = logs_ref.stream()

        all_logs = []

        for doc in docs:
            log_data = doc.to_dict()

            if "login_time" in log_data:
                log_data["login_time"] = log_data["login_time"].strftime("%Y-%m-%d %H:%M:%S")
            
            all_logs.append(log_data)

        return {"status": "success", "logs": all_logs}
    except Exception as e:
        
        raise HTTPException(status_code=500, detail=str(e))



# Logic: We fetch all events and filter them in Python for flexibility
# @app.get("/events")
# async def get_events(search: str = None, date: str = None):
#     try:
#         events_ref = db.collection("events")
#         docs = events_ref.stream()
#         results = []

#         for doc in docs:
#             event = doc.to_dict()
#             event["id"] = doc.id
            
#             # 1. Date Filter: Comparing the string from UI to DB
#             if date and date != "All" and event.get("date") != date:
#                 continue
            
#             # 2. Search Logic: Checking title and description
#             if search:
#                 s = search.lower()
#                 if s not in event.get("title", "").lower() and s not in event.get("description", "").lower():
#                     continue
            
#             results.append(event)
#         return {"status": "success", "events": results}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

# @app.get("/events")
# async def get_events(search: str = None, date: str = None, page: int = 1, limit: int = 5):
#     try:
#         query = db.collection("events")

#         if date and date != "All":
#             query = query.where("date", "==", date)

#         skip = (page - 1) * limit
#         docs = query.offset(skip).limit(limit).stream()

#         query = query.order_by("date")

#         docs = query.stream()
#         results = []

#         for doc in docs:
#             event = doc.to_dict()
#             event["id"] = doc.id
            
#             if search:
#                 s = search.strip().lower()
#                 if s not in event.get("title", "").lower() and s not in event.get("description", "").lower():
#                     continue
            
#             results.append(event)
            
#         return {"status": "success", "events": results}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

@app.get("/events")
async def get_events(search: str = None, date : str = None, page : int =1, limit: int = 5):
    try:
        query = supabase.table("events").select("*")

        if date and date != "All":
            query = query.gte("event_date", f"{date}T00:00:00")\
                         .lt("event_date", f"{date}T23:59:59")
        
        start = (page-1)* limit
        end = start + limit -1
        query = query.range(start, end).order("event_date")

        response = query.order("event_date", desc=False).range(start, end).execute()
        events = response.data

        if search:
            s = search.strip().lower()
            events = [
                e for e in events
                if s in e.get("title", "").lower() or s in e.get("description", "").lower()
            ]
        return {"status": "success", "event": events}
    except Exception as e:
        print(f"DEBUG ERROR: {e}")
        raise HTTPException(status_code=500,detail=str(e))

# @app.get("/events")
# async def get_events(search: str = None, date: str = None, page: int = 1, limit: int = 5):
#     try:
#         # 1. SIMPLEST POSSIBLE QUERY
#         # We use .from_("events") or .table("events")
#         response = supabase.table("events").select("*").execute()
        
#         print(f"RAW DATA FROM SUPABASE: {response.data}") # CHECK YOUR TERMINAL
        
#         return {"status": "success", "events": response.data}

#     except Exception as e:
#         print(f"STILL FAILING: {e}")
#         raise HTTPException(status_code=500, detail=str(e))