from fastapi import FastAPI
from routes import auth, song
from models.base import Base
from database import engine


app = FastAPI()
app.include_router(auth.router, prefix = '/auth')
app.include_router(song.router, prefix = '/song')

Base.metadata.create_all(engine)
#------------------------------------------------------------------------#
# import os
# from dotenv import load_dotenv

# # Load the .env file
# load_dotenv()

# Access the variables

# api_key = os.getenv("API_KEY")
# api_secret_key = os.getenv("API_SECRET_KEY")


# print(type(api_key), type(api_secret_key))  # Output: abcd1234efgh5678

# Rest of your app code here


# def test():
#     return 'hello'
# ## SHORTER (NOT MUCH EFFICIENT WAY, FOR bigger programs) WAY to access response body

# async def test(request: Request):
#     print((await request.body()).decode())
#     return "Hello 555"

# class Test(BaseModel):
#     name: str
#     age: int
    
# @app.post('/')
# ### LONGER (EFFICIENT WAY)
# def test(t: Test, q: str):
#     print(t)
#     return {"message": f"Hello {t.name}"}