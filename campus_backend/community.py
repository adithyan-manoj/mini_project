from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
import os
from supabase import create_client, Client
from dotenv import load_dotenv
from ai_utils import upsert_document

load_dotenv()

# ── Supabase client ───────────────────────────────────────────────────────────
supabase_url = os.getenv("supabase_url")
supabase_key = os.getenv("supabase_key")

supabase: Client = create_client(supabase_url, supabase_key)

# ── Router ────────────────────────────────────────────────────────────────────
router = APIRouter(prefix="/community", tags=["Community"])


# ── Pydantic models ───────────────────────────────────────────────────────────
class PostCreate(BaseModel):
    title: str
    content: str
    author_id: Optional[str] = None


class CommentCreate(BaseModel):
    content: str
    author_id: Optional[str] = None
    parent_comment_id: Optional[str] = None   # None = top-level comment; UUID = reply


# ─────────────────────────────────────────────────────────────────────────────
#  POSTS
# ─────────────────────────────────────────────────────────────────────────────

@router.get("/posts")
async def get_posts():
    """Return all community posts ordered by newest first."""
    try:
        response = (
            supabase.from_("posts")
            .select("*, author:users(full_name, profile_pic_url)")
            .order("created_at", desc=True)
            .execute()
        )
        return {"status": "success", "posts": response.data}
    except Exception as e:
        print(f"get_posts error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/posts")
async def create_post(post: PostCreate):
    """Insert a new community post into Supabase."""
    try:
        payload: Dict[str, Any] = {
            "title": post.title,
            "content": post.content,
        }
        if post.author_id:
            payload["author_id"] = post.author_id

        response = supabase.table("posts").insert(payload).execute()

        # 🧠 AI Real-time Ingestion (RAG)
        try:
            post_id = response.data[0]['id']
            content = f"Post Title: {post.title}. Content: {post.content}."
            metadata = {
                "type": "post",
                "id": str(post_id),
                "title": post.title,
                "path": "/community" # Deep link path
            }
            upsert_document(content, metadata)
        except Exception as ai_err:
            print(f"⚠️ AI Ingestion Warning: {ai_err}")

        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"create_post error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ─────────────────────────────────────────────────────────────────────────────
#  COMMENTS
# ─────────────────────────────────────────────────────────────────────────────

@router.get("/posts/{post_id}/comments")
async def get_comments(post_id: str):
    """
    Return all comments for a post as a flat list ordered by created_at.
    Tree assembly (parent → children nesting) is done on the Flutter side.
    """
    try:
        response = (
            supabase.from_("comments")
            .select("*, author:users(full_name, profile_pic_url)")
            .eq("post_id", post_id)
            .order("created_at", desc=False)
            .execute()
        )
        return {"status": "success", "comments": response.data}
    except Exception as e:
        print(f"get_comments error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/posts/{post_id}/comments")
async def create_comment(post_id: str, comment: CommentCreate):
    """
    Insert a new comment (or reply) for the given post.
    - If parent_comment_id is omitted/null → top-level comment.
    - If parent_comment_id is a UUID → reply to that comment.
    """
    try:
        payload: Dict[str, Any] = {
            "post_id": post_id,
            "content": comment.content,
        }
        if comment.author_id:
            payload["author_id"] = comment.author_id
        if comment.parent_comment_id:
            payload["parent_comment_id"] = comment.parent_comment_id

        response = supabase.table("comments").insert(payload).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"create_comment error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ─────────────────────────────────────────────────────────────────────────────
#  LIKES
# ─────────────────────────────────────────────────────────────────────────────

@router.post("/posts/{post_id}/like")
async def like_post(post_id: str):
    """Increment the likes_count of a post."""
    try:
        response = supabase.table("posts").select("likes_count").eq("id", post_id).single().execute()
        current_likes = response.data.get("likes_count") or 0
        new_likes = current_likes + 1
        supabase.table("posts").update({"likes_count": new_likes}).eq("id", post_id).execute()
        return {"status": "success", "likes_count": new_likes}
    except Exception as e:
        print(f"like_post error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/posts/{post_id}/unlike")
async def unlike_post(post_id: str):
    """Decrement the likes_count of a post."""
    try:
        response = supabase.table("posts").select("likes_count").eq("id", post_id).single().execute()
        current_likes = response.data.get("likes_count") or 0
        new_likes = max(0, current_likes - 1)
        supabase.table("posts").update({"likes_count": new_likes}).eq("id", post_id).execute()
        return {"status": "success", "likes_count": new_likes}
    except Exception as e:
        print(f"unlike_post error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
