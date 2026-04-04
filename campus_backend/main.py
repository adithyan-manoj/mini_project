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

import firebase_admin
from firebase_admin import credentials, messaging
from typing import Optional, List
from groq import Groq
from ai_utils import upsert_document, search_documents

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

# ── Firebase Initialization ──────────────────────────────────────────────────
try:
    cred_path = os.path.join(os.path.dirname(__file__), "serviceaccount.json")
    if os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("✅ SUCCESS: Firebase Admin SDK initialized.")
    else:
        print("⚠️ WARNING: service-account.json NOT FOUND. Push notifications will fail.")
except Exception as e:
    print(f"❌ Firebase Init Error: {e}")

#supabase
load_dotenv()

supabase_url = os.getenv("supabase_url") or "https://lynzclilcsykpakjezuv.supabase.co"
supabase_key = os.getenv("supabase_key") or "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bnpjbGlsY3N5a3Bha2plenV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MjgxMzUsImV4cCI6MjA4NzUwNDEzNX0.DmjpHqrSu4WffjYCO2O-yK7sJMHonqkAC5g1Z9quQm4"
supabase_service_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("supabase_service_key")

if not supabase_service_key or supabase_service_key == supabase_key:
    print("⚠️ WARNING: SUPABASE_SERVICE_ROLE_KEY is missing or invalid! Admin features like creating users will FAIL.")
else:
    print("✅ SUCCESS: Supabase Service Role Key loaded.")

supabase1: Client = create_client(supabase_url, supabase_service_key)

# Secondary Supabase (for specific features if needed)
supabase_url_sec = "https://hmbfexybfgpmbrsisdfi.supabase.co"
supabase_key_sec = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhtYmZleHliZmdwbWJyc2lzZGZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1ODU1ODMsImV4cCI6MjA4OTE2MTU4M30.zeEUk-kcmzadiimcTzejKPpAZDdBGRwOuXeA3B_gA2Q"
supabase: Client = create_client(supabase_url_sec, supabase_key_sec)

# ── Models ────────────────────────────────────────────────────────────────────

class EtLabCredentials(BaseModel):
    username:str
    password:str

class AdminCreateUser(BaseModel):
    email: str
    password: str
    full_name: str
    role: str # 'staff' or 'club_rep'

class EventCreate(BaseModel):
    title: str
    description: str
    venue: str
    event_date: str
    image_url: str

class FCMUpdate(BaseModel):
    user_id: str
    fcm_token: str

class LostFoundItem(BaseModel):
    title: str
    description: str
    type: str           # "lost" or "found"
    category: str
    location: str
    contact_info: str
    posted_by: str
    image_url: Optional[str] = None

class StatusUpdate(BaseModel):
    status: str

class ChatRequest(BaseModel):
    query: str
    user_id: Optional[str] = None

# ── Authentication ─────────────────────────────────────────────────────────────

ETLAB_URL = "https://sctce.etlab.in/user/login"

@app.post("/login")
async def login_to_etlab(data: EtLabCredentials):
    # --- DUAL-MODE LOGIN: Check for Email vs ETLAB ID ---
    if "@" in data.username:
        try:
            auth_res = supabase1.auth.sign_in_with_password({
                "email": data.username,
                "password": data.password
            })
            user_id = auth_res.user.id
            user_profile = supabase1.table("users").select("*").eq("id", user_id).single().execute()
            
            clean_session = {
                "access_token": auth_res.session.access_token,
                "refresh_token": auth_res.session.refresh_token,
                "expires_at": auth_res.session.expires_at
            }
            
            return {
                "status": "success",
                "message": "Authenticated with Supabase",
                "session": clean_session,
                "user": user_profile.data
            }
        except Exception as e:
            print(f"Internal Login Error: {e}")
            raise HTTPException(status_code=401, detail="Invalid Email or Password")

    # --- ETLAB LOGIN (Students) ---
    session = requests.Session()
    payload = {
        "LoginForm[username]": data.username,
        "LoginForm[password]": data.password,
        "yt0": "Login" 
    }
    
    try:
        response = session.post(ETLAB_URL, data=payload, timeout=15)

        if response.status_code == 200 and "Dashboard" in response.text:
            try:
                from bs4 import BeautifulSoup
                import re
                
                profile_res = session.get("https://sctce.etlab.in/student/profile", timeout=10)
                soup = BeautifulSoup(profile_res.text, 'html.parser')
                
                # Fetch student profile data
                full_name = f"User {data.username}"
                name_th = soup.find('th', string=re.compile(r'Name', re.I))
                if name_th and name_th.find_next_sibling('td'):
                    full_name = name_th.find_next_sibling('td').get_text(strip=True)
                
                department = "Pending"
                dept_th = soup.find('th', string=re.compile(r'^\s*(Course|Department|Branch)\s*$', re.I))
                if dept_th and dept_th.find_next_sibling('td'):
                    department = dept_th.find_next_sibling('td').get_text(strip=True)
                
                profile_pic_url = f"https://api.dicebear.com/7.x/avataaars/png?seed={data.username}"
                img_elem = soup.find('img', id='photo') or soup.find('img', class_='span2')
                if img_elem and 'src' in img_elem.attrs:
                    src = img_elem['src']
                    profile_pic_url = src if src.startswith('http') else f"https://sctce.etlab.in{src}"
                
                # ── 🔍 SYNC STRATEGY: Auth First, Profile Second ──────────────────
                dummy_email = f"{data.username}@sctce.ac.in"
                
                # Check if user already has a profile mapped
                existing_user = supabase1.table("users").select("id").eq("etlab_id", data.username).execute()
                known_id = existing_user.data[0]["id"] if existing_user.data else None

                # 1. ⚡ STEP 1: Attempt to Authenticate First
                try:
                    auth_res = supabase1.auth.sign_in_with_password({
                        "email": dummy_email,
                        "password": data.password
                    })
                except Exception as sign_in_error:
                    # Authentication failed. This could be due to wrong password OR user doesn't exist yet.
                    users_res = supabase1.auth.admin.list_users()
                    ulist = getattr(users_res, 'users', users_res)
                    target = next((u for u in ulist if u.email == dummy_email), None)
                    
                    if not target:
                        # User doesn't exist, create them!
                        try:
                            supabase1.auth.admin.create_user({
                                "email": dummy_email,
                                "password": data.password,
                                "user_metadata": {"full_name": full_name},
                                "email_confirm": True
                            })
                            # Sign in to get the session token
                            auth_res = supabase1.auth.sign_in_with_password({
                                "email": dummy_email,
                                "password": data.password
                            })
                        except Exception as create_error:
                            print(f"CRITICAL: Failed to create new user - {create_error}")
                            raise HTTPException(status_code=500, detail=f"User creation failed: {create_error}")
                    else:
                        # User exists, but password was wrong. Try to force sync the password!
                        try:
                            supabase1.auth.admin.update_user_by_id(target.id, {"password": data.password})
                            auth_res = supabase1.auth.sign_in_with_password({
                                "email": dummy_email,
                                "password": data.password
                            })
                        except Exception as e:
                            print(f"⚠️ Password Sync Warning: {e}")
                            raise HTTPException(status_code=401, detail="ETLAB Login ok, but failed to sync internal authentication.")

                user_id = auth_res.user.id
                print(f"DEBUG SYNC: Login OK for {data.username}. Auth ID: {user_id}")

                # ── 🚨 DEV DATA REPAIR: Fix Identity Mismatches ─────────────
                if known_id and known_id != user_id:
                    print(f"⚠️ ID Mismatch Detected! Migrating data from {known_id} to {user_id}...")
                    def migrate_table(table, column):
                        try:
                            res = supabase1.table(table).update({column: user_id}).eq(column, known_id).execute()
                            print(f" -> Migrated {table}")
                        except Exception as e:
                            print(f" -> Failed {table}: {e}")
                    
                    migrate_table("posts", "author_id")
                    migrate_table("comments", "user_id")
                    migrate_table("likes", "user_id")
                    migrate_table("harassment_reports", "reporter_id")
                    migrate_table("lost_and_found", "posted_by")

                    try:
                        supabase1.table("users").delete().eq("id", known_id).execute()
                        print(" -> Purged old ghost profile.")
                    except Exception as e:
                        print(f" -> Failed to purge old profile: {e}")

                # 3. ⚡ STEP 3: Sync Profile Table
                upsert_res = supabase1.table("users").upsert({
                    "id": user_id, 
                    "etlab_id": data.username,
                    "full_name": full_name,
                    "department": department,
                    "profile_pic_url": profile_pic_url
                }, on_conflict="etlab_id").execute()
                
                final_user_profile = upsert_res.data[0] if upsert_res.data else {"id": user_id, "full_name": full_name}

                # Prepare session packet
                clean_session = {
                    "access_token": auth_res.session.access_token,
                    "refresh_token": auth_res.session.refresh_token,
                    "expires_at": auth_res.session.expires_at
                }

                print(f"✅ SUCCESS: Profile Ready for student {user_id}")
                return {
                    "status": "success",
                    "session": clean_session,
                    "user": final_user_profile
                }
                
            except Exception as e:
                import traceback
                traceback.print_exc()
                print(f"CRITICAL PROFILE SYNC ERROR: {e}")
                raise HTTPException(status_code=500, detail=f"Database Profile Sync Failed: {str(e)}")
        else:
            raise HTTPException(status_code=401, detail="Invalid ETLAB credentials")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/admin/create-user")
async def admin_create_user(data: AdminCreateUser):
    print(f"DEBUG ADMIN: Handshaking {data.email}")
    try:
        # Create Auth user (or ignore if exists)
        try:
            auth_res = supabase1.auth.admin.create_user({
                "email": data.email,
                "password": data.password,
                "user_metadata": {"full_name": data.full_name},
                "email_confirm": True
            })
            user_id = auth_res.user.id
        except Exception as auth_err:
            if "already been registered" in str(auth_err):
                # Fetch UID safely using the email
                # admin.list_users is used sparingly to avoid 403.
                users_res = supabase1.auth.admin.list_users()
                ulist = getattr(users_res, 'users', users_res)
                target = next((u for u in ulist if u.email == data.email), None)
                if not target: raise auth_err
                user_id = target.id
            else: raise auth_err

        # Upsert with ID as primary key
        supabase1.table("users").upsert({
            "id": user_id,
            "etlab_id": f"INTERNAL_{data.email}", 
            "full_name": data.full_name,
            "role": data.role.lower(),
            "profile_pic_url": f"https://api.dicebear.com/7.x/avataaars/png?seed={data.full_name}"
        }, on_conflict="id").execute()
        
        return {"status": "success", "message": f"Setup {data.role} account."}
    except Exception as e:
        print(f"CRITICAL ADMIN ERROR: {e}")
        raise HTTPException(status_code=500, detail=f"Setup Failed: {str(e)}")

@app.get("/user/profile/{user_id}")
async def get_user_profile(user_id: str):
    response = supabase1.table("users").select("*").eq("id", user_id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="User not found")
    return {"status": "success", "user": response.data[0]}

@app.post("/user/update-fcm")
async def update_fcm_token(data: FCMUpdate):
    try:
        supabase1.table("users").update({"fcm_token": data.fcm_token}).eq("id", data.user_id).execute()
        return {"status": "success", "message": "FCM Token updated"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ── Events ────────────────────────────────────────────────────────────────────

@app.get("/events")
async def get_events(search: str = None, date : str = None, page : int =1, limit: int = 5):
    try:
        query = supabase1.table("events").select("*")
        if date and date != "All":
            query = query.gte("event_date", f"{date}T00:00:00")\
                         .lt("event_date", f"{date}T23:59:59")
        start = (page-1)* limit
        end = start + limit -1
        response = query.order("event_date", desc=False).range(start, end).execute()
        events = response.data
        if search:
            s = search.strip().lower()
            events = [e for e in events if s in e.get("title", "").lower() or s in e.get("description", "").lower()]
        return {"status": "success", "event": events}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

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
        # 1. Insert into database
        response = supabase1.table("events").insert(data).execute()
        
        # 2. 📡 Broadcast Push Notification
        try:
            tokens_res = supabase1.table("users").select("fcm_token").not_.is_("fcm_token", "null").execute()
            tokens = [r["fcm_token"] for r in tokens_res.data if r.get("fcm_token")]
            
            if tokens:
                message = messaging.MulticastMessage(
                    notification=messaging.Notification(
                        title=f"New Event: {event.title}",
                        body=f"Join us at {event.venue} on {event.event_date}!",
                    ),
                    tokens=tokens,
                )
                messaging.send_multicast(message)
                print(f"✅ SUCCESS: Broadcasted event notification to {len(tokens)} users.")
        except Exception as fcm_err:
            print(f"⚠️ FCM Broadcast Error: {fcm_err}")

        # 3. 🧠 AI Real-time Ingestion (RAG)
        try:
            event_id = response.data[0]['id']
            content = f"Event: {event.title}. Description: {event.description}. Venue: {event.venue}. Date: {event.event_date}."
            metadata = {
                "type": "event",
                "id": str(event_id),
                "title": event.title,
                "path": "/events" # Deep link path
            }
            upsert_document(content, metadata)
        except Exception as ai_err:
            print(f"⚠️ AI Ingestion Warning: {ai_err}")

        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ── Lost and Found ────────────────────────────────────────────────────────────

@app.get("/lost-found")
async def get_lost_found_items(type: str = None, category: str = None, status: str = None):
    try:
        query = supabase.table("lost_and_found").select("*").order("created_at", desc=True)
        if type: query = query.eq("type", type)
        if category: query = query.eq("category", category)
        if status: query = query.eq("status", status)
        response = query.execute()
        return {"status": "success", "items": response.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/lost-found/{item_id}")
async def get_lost_found_item(item_id: str):
    response = supabase.table("lost_and_found").select("*").eq("id", item_id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"status": "success", "item": response.data[0]}

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
            "status": "active"
        }
        response = supabase.table("lost_and_found").insert(data).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.patch("/lost-found/{item_id}/status")
async def update_item_status(item_id: str, data: StatusUpdate):
    try:
        response = supabase.table("lost_and_found").update({"status": data.status}).eq("id", item_id).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
class ChatRequest(BaseModel):
    query: str
    user_id: Optional[str] = None

#      AI Chat Bot                                                                                                                               

@app.post("/ai/chat")
async def ai_chat(request: ChatRequest):
    """AI Chatbot with RAG (Retrieval-Augmented Generation) and Deep Linking."""
    try:
        # 1. Search for relevant context in the Knowledge Base
        context_chunks = search_documents(request.query)
        context_text = "\n".join([c['content'] for c in context_chunks])
        
        # 2. Extract links/metadata from the context for reference
        # This helps the AI know which IDs correspond to which items
        source_links = []
        for c in context_chunks:
            meta = c.get('metadata', {})
            source_links.append({
                "id": meta.get("id"),
                "type": meta.get("type"),
                "title": meta.get("title")
            })

        # 3. Setup Groq Model
        client = Groq(api_key=os.getenv("GROQ_API_KEY"))
        
        system_prompt = f"""
        You are the Campus Assistant for 'Campus App'. You help students with college events, community posts, and campus info.
        Use the following context to answer the user's question accurately. Be friendly and direct.
        
        CONTEXT:
        {context_text}
        
        METADATA (Use these IDs for deep linking):
        {source_links}

        RULES:
        1. Be helpful and professional.
        2. IF you mention a specific event or post from the context, you MUST include its ID, title, and type in the 'links' list.
        3. ALWAYS return a valid JSON object.
        4. YOU MUST RESPOND ONLY IN JSON FORMAT.
        5. The JSON format must be:
        {{
            "answer": "Your detailed response here...",
            "links": [{{ "type": "event/post", "id": "uuid", "title": "name" }}]
        }}
        """

        response = client.chat.completions.create(
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": request.query}
            ],
            model="llama-3.3-70b-versatile",
            response_format={"type": "json_object"}
        )

        import json
        ai_response = json.loads(response.choices[0].message.content)
        
        return {
            "status": "success",
            "answer": ai_response.get("answer"),
            "links": ai_response.get("links", [])
        }

    except Exception as e:
        print(f"R AI Chat Error: {e}")
        raise HTTPException(status_code=500, detail=f"AI Assistant unavailable: {str(e)}")
