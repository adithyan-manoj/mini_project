import os
from dotenv import load_dotenv
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
from supabase import create_client, Client
from fastapi.middleware.cors import CORSMiddleware
from community import router as community_router
from harassment import router as harassment_router
from backup_lost_found import router as backup_lost_found_router

from typing import Optional

app = FastAPI()

# ── Include routers ────────────────────────────────────────────────────────────
app.include_router(community_router)
app.include_router(harassment_router)
app.include_router(backup_lost_found_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows all devices
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# # cred = credentials.Certificate("D:\Flutter study\mini project\campus_backend\serviceAccountKey.json")
# # firebase_admin.initialize_app(cred)
# db = firestore.client()





#supabase
load_dotenv()

supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("supabase_key")
supabase_service_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv(
    "supabase_service_key"
)
supabase_url = "https://lynzclilcsykpakjezuv.supabase.co"
supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bnpjbGlsY3N5a3Bha2plenV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MjgxMzUsImV4cCI6MjA4NzUwNDEzNX0.DmjpHqrSu4WffjYCO2O-yK7sJMHonqkAC5g1Z9quQm4"
 

supabase1: Client = create_client(supabase_url, supabase_service_key)
supabase_url1 = "https://hmbfexybfgpmbrsisdfi.supabase.co"
supabase_key1 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhtYmZleHliZmdwbWJyc2lzZGZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1ODU1ODMsImV4cCI6MjA4OTE2MTU4M30.zeEUk-kcmzadiimcTzejKPpAZDdBGRwOuXeA3B_gA2Q"

supabase: Client = create_client(supabase_url1, supabase_key1)

class EventCreate(BaseModel):  #for events
    title: str
    description: str
    venue: str
    event_date: str
    image_url: str

#suraaa


class LostFoundItem(BaseModel):  # for lost and found
    title: str
    description: str
    type: str          # "lost" or "found"
    category: str
    location: str
    contact_info: str
    posted_by: str
    image_url: str = None  # optional

class StatusUpdate(BaseModel):
    status: str  # "open" or "resolved"

class LostFoundItem(BaseModel): #for lost and found
    title: str
    description: str
    type: str           # "lost" or "found"
    category: str
    location: str
    contact_info: str
    posted_by: str
    image_url: Optional[str] = None  # ← THIS ACCEPTS null properly




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
        # 1. Verify with ETLAB
        response = session.post(ETLAB_URL, data=payload, timeout=10)

        if response.status_code == 200 and "Dashboard" in response.text:
            # Fix: Splitting logic for the name
            full_name = f"User {data.username}" 
            if "Welcome," in response.text:
                try:
                    # Fix: Correctly indexing the split list before splitting again
                    full_name = response.text.split("Welcome,").split("!").strip()
                except (IndexError, AttributeError):
                    pass

            user_email = f"{data.username}@sctce.edu"
            auth_res = None

            try:
                # 2. Try to Sign In (if user already exists)
                auth_res = supabase1.auth.sign_in_with_password({
                    "email": user_email, 
                    "password": data.password
                })
            except Exception:
                # 3. Create New User if Sign In fails
                try:
                    # Admin create doesn't return a session, just the user
                    supabase1.auth.admin.create_user({
                        "email": user_email,
                        "password": data.password,
                        "user_metadata": {"full_name": full_name},
                        "email_confirm": True
                    })
                    # MUST sign in after creation to get the Session object for Flutter
                    auth_res = supabase1.auth.sign_in_with_password({
                        "email": user_email, 
                        "password": data.password
                    })
                except Exception as create_err:
                    # 4. Fallback: Password mismatch on existing account
                    users_list = supabase1.auth.admin.list_users()
                    target_user = next((u for u in users_list if u.email == user_email), None)
                    
                    if target_user:
                        supabase1.auth.admin.update_user_by_id(
                            target_user.id, 
                            attributes={'password': data.password}
                        )
                        auth_res = supabase1.auth.sign_in_with_password({
                            "email": user_email, 
                            "password": data.password
                        })
                    else:
                        raise create_err

            user_id = auth_res.user.id

            # 5. Sync to systematic 'users' table
            supabase1.table("users").upsert({
                "id": user_id,
                "etlab_id": data.username,
                "full_name": full_name,
                "department": "Pending", 
            }).execute()

            # Return the session object which Flutter's ApiService expects
            clean_session = {
                "access_token": auth_res.session.access_token,
                "refresh_token": auth_res.session.refresh_token,
                "expires_at": auth_res.session.expires_at
            }
            
            return {
                "status": "success",
                "message": "Authenticated with ETLAB and Supabase",
                "session": clean_session,
                "user": {
                    "id": user_id,
                    "name": full_name
                }
            }
            
        else:
            raise HTTPException(status_code=401, detail="Invalid ETLAB credentials")

    except Exception as e:
        print(f"Login Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/user/profile/{user_id}")
async def get_user_profile(user_id: str):
    try:
        # Query the systematic 'users' table
        response = supabase1.table("users").select("*").eq("id", user_id).execute()
        
        if not response.data:
            raise HTTPException(status_code=404, detail="User not found")
            
        return {
            "status": "success", 
            "user": response.data[0]
        }
    except Exception as e:
        print(f"Profile Fetch Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
    

# @app.get("/admin/logs")
# async def get_all_logs():
#     try:
#         logs_ref = db.collection("login_logs")

#         docs = logs_ref.stream()

#         all_logs = []

#         for doc in docs:
#             log_data = doc.to_dict()

#             if "login_time" in log_data:
#                 log_data["login_time"] = log_data["login_time"].strftime("%Y-%m-%d %H:%M:%S")
            
#             all_logs.append(log_data)

#         return {"status": "success", "logs": all_logs}
#     except Exception as e:
        
#         raise HTTPException(status_code=500, detail=str(e))



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
        query = supabase1.table("events").select("*")

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

@app.post("/events_post")
async def add_event(event: EventCreate):
    try:
        data = {
            "title": event.title,
            "description": event.description,
            "venue": event.venue,
            "event_date": event.event_date,
            "image_url": event.image_url
        }
        response = supabase1.table("events").insert(data).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"Server Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


#suraa

@app.get("/lost-found")
async def get_lost_found_items(type: str = None, category: str = None, status: str = None):
    try:
        query = supabase.table("lost_and_found").select("*").order("created_at", desc=True)

        if type:
            query = query.eq("type", type)
        if category:
            query = query.eq("category", category)
        if status:
            query = query.eq("status", status)

        response = query.execute()
        return {"status": "success", "items": response.data}
    except Exception as e:
        print(f"DEBUG ERROR: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# GET single item by ID
@app.get("/lost-found/{item_id}")
async def get_lost_found_item(item_id: str):
    try:
        response = supabase.table("lost_and_found").select("*").eq("id", item_id).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Item not found")
        return {"status": "success", "item": response.data[0]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# POST — report a new lost or found item
@app.post("/lost-found")
async def create_lost_found_item(item: LostFoundItem):
    try:
        data = {
            "title": item.title,
            "description": item.description,
            "type": item.type,
            "category": item.category,
            "location": item.location,
            "contact_info": item.contact_info,
            "posted_by": item.posted_by,
            "image_url": item.image_url,
            "status": "open"
        }
        response = supabase.table("lost_and_found").insert(data).execute()
        return {"status": "success", "item": response.data[0]}
    except Exception as e:
        print(f"Server Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# PATCH — mark item as resolved or reopen it
@app.patch("/lost-found/{item_id}/status")
async def update_lost_found_status(item_id: str, update: StatusUpdate):
    try:
        response = supabase.table("lost_and_found")\
            .update({"status": update.status})\
            .eq("id", item_id)\
            .execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Item not found")
        return {"status": "success", "item": response.data[0]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# DELETE — remove a post
@app.delete("/lost-found/{item_id}")
async def delete_lost_found_item(item_id: str):
    try:
        supabase.table("lost_and_found").delete().eq("id", item_id).execute()
        return {"status": "success", "message": "Item deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# GET — search by keyword in title or description
@app.get("/lost-found-search")
async def search_lost_found(q: str):
    try:
        response = supabase.table("lost_and_found")\
            .select("*")\
            .ilike("title", f"%{q}%")\
            .execute()
        return {"status": "success", "items": response.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))