# from fastapi import FastAPI, HTTPException
# from pydantic import BaseModel, EmailStr
# from fastapi.middleware.cors import CORSMiddleware

# app = FastAPI()

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )


# class UserSignup(BaseModel):
#     #username: str
#     email: EmailStr
#     password: str

# class UserLogin(BaseModel):
#     #username: str
#     email: EmailStr
#     password: str


# @app.post("/signup")
# def create_account(user: UserSignup):
#     print(f"New User: {user.username} is signing up!")

#     return {
#         "message": "Account created successfully",
#         "user_email": user.email
#     }

# @app.post("/login")
# async def login_user(user: UserLogin):
#     # This logic checks the credentials
#     if user.email == "test@gmail.com" and user.password == "12345678":
#         return {"status": "success", "message": "welcome to campus"}
#     #return {"access": "denied", "error": "Wrong credentials"} 
#     raise HTTPException(status_code=401, detail="Invalid email or password")