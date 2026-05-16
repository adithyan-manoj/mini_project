import os
from dotenv import load_dotenv
from ai_utils import upsert_document

load_dotenv()

def seed_app_details():
    print("🚀 Seeding Campus App details into the Knowledge Base...")

    app_knowledge = [
        {
            "title": "AI Chatbot Assistant",
            "content": (
                "The Campus AI Assistant is a central feature of the Campus App. "
                "It uses Retrieval-Augmented Generation (RAG) to provide accurate answers about campus events and community posts. "
                "It features persistent conversation memory, allowing it to remember context from previous messages in the same session. "
                "It also provides deep links to events and posts, allowing users to navigate directly from the chat."
            ),
            "id": "feat_ai_chat"
        },
        {
            "title": "Community Posts and Networking",
            "content": (
                "The Community section allows students to share updates, ask questions, and start discussions. "
                "Users can create posts with titles and descriptions, like posts they find interesting, and engage in "
                "threaded conversations through nested comments. The community feed supports offline viewing for previously loaded data."
            ),
            "id": "feat_community"
        },
        {
            "title": "Event Discovery and Management",
            "content": (
                "The Events section is for discovering and managing campus activities. "
                "Students can filter events by date or search for specific keywords. "
                "Creation of events is restricted to authenticated 'Admin' and 'Club Representative' roles. "
                "Event details include the venue, date, time, and a descriptive summary."
            ),
            "id": "feat_events"
        },
        {
            "title": "Lost and Found Management",
            "content": (
                "The Lost and Found page allows students to report missing items or items they have found on campus. "
                "Users can search for specific items and mark entries as 'Resolved' once the item is returned to its owner. "
                "It helps keep the campus organized and supportive."
            ),
            "id": "feat_lost_found"
        },
        {
            "title": "Offline Caching and Performance",
            "content": (
                "The Campus App features a robust local caching system powered by Hive. "
                "Even without an internet connection, students can view their recently loaded community posts, events, and AI chat history. "
                "This ensures the app is always fast and responsive, providing a premium user experience."
            ),
            "id": "feat_performance"
        },
        {
            "title": "User Roles and Permissions",
            "content": (
                "Access to features in the Campus App is governed by user roles: "
                "1. Students: Can view all content, create community posts, and participate in discussions. "
                "2. Club Representatives: Have the additional ability to create and manage campus events. "
                "3. Staff/Monitors: Can monitor harassment reports and maintain campus safety. "
                "4. Admins: Have full control, including user management and system logs."
            ),
            "id": "feat_roles"
        },
        {
            "title": "Modern User Interface",
            "content": (
                "The app uses a modern design system with a dark theme, vibrant accents, and high-quality typography. "
                "It features shimmer skeleton loaders for a smooth transition while data is fetching and interactive animations for AI interactions, "
                "such as the typing indicator in the chat."
            ),
            "id": "feat_ui"
        }
    ]

    for item in app_knowledge:
        metadata = {
            "type": "appinfo",
            "id": item["id"],
            "title": item["title"],
            "category": "manual"
        }
        upsert_document(item["content"], metadata)
        print(f"✅ Indexed: {item['title']}")

    print("🏁 App Knowledge seeding complete!")

if __name__ == "__main__":
    seed_app_details()
