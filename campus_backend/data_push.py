import firebase_admin
from firebase_admin import credentials, firestore

# Ensure the path matches your Dell Latitude 7480 directory structure
cred = credentials.Certificate("D:\Flutter study\mini project\campus_backend\serviceAccountKey.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

dummy_events = [
    {
        "title": "CodereCET Hackathon",
        "description": "A decentralized platform leveraging blockchain to track carbon credits. Build with Solidity and React.",
        "venue": "CET Trivandrum",
        "date": "2026-02-23",
        "image_url": "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=400"
    },
    {
        "title": "AI & Flutter Workshop",
        "description": "Learn to integrate Gemini 3.5 into your mobile apps. Hands-on training for beginners in AI.",
        "venue": "Main Block Seminar Hall",
        "date": "2026-02-24",
        "image_url": "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=400"
    },
    {
        "title": "Retro Racing Tournament",
        "description": "A classic gaming night featuring arcade racing and vintage console challenges. Prizes for top 3.",
        "venue": "Student Activity Center",
        "date": "2026-02-24",
        "image_url": "https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=400"
    },
    {
        "title": "Campus Music Fest",
        "description": "Live acoustic performances by local campus bands. Join us for an evening of melody and fun.",
        "venue": "Open Air Theater",
        "date": "2026-02-25",
        "image_url": "https://images.unsplash.com/photo-1459749411177-042180ceea72?auto=format&fit=crop&w=400"
    },
    {
        "title": "Placement Prep Seminar",
        "description": "Expert talk on technical interviews and resume building for CS students. Don't miss out.",
        "venue": "Diamond Jubilee Hall",
        "date": "2026-02-26",
        "image_url": "https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=400"
    },
    {
        "title": "Inter-College Cricket Finals",
        "description": "The final showdown between CET and GEC teams. Come and cheer for our campus champions.",
        "venue": "College Ground",
        "date": "2026-02-27",
        "image_url": "https://images.unsplash.com/photo-1531415074968-036ba1b575da?auto=format&fit=crop&w=400"
    }
]

for event in dummy_events:
    # Adding to the 'events' collection used by your FastAPI backend
    db.collection("events").add(event)
    print(f"Successfully Added: {event['title']}")