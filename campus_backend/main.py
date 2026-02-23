import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

app = FastAPI()

cred = credentials.Certificate("D:\Flutter study\mini project\campus_backend\serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


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
@app.get("/events")
async def get_events(search: str = None, date: str = None):
    try:
        events_ref = db.collection("events")
        docs = events_ref.stream()
        results = []

        for doc in docs:
            event = doc.to_dict()
            event["id"] = doc.id
            
            # 1. Date Filter: Comparing the string from UI to DB
            if date and date != "All" and event.get("date") != date:
                continue
            
            # 2. Search Logic: Checking title and description
            if search:
                s = search.lower()
                if s not in event.get("title", "").lower() and s not in event.get("description", "").lower():
                    continue
            
            results.append(event)
        return {"status": "success", "events": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))