import uuid
import bcrypt
from fastapi import Depends, HTTPException, Header
import jwt
from mysqlx import Session
from database import get_db
from sqlalchemy.orm import joinedload
from middleware.auth_middleware import auth_middleware
from models.favourite import Favourite
from models.user import User
from pydantic_schemas.user_create import UserCreate
from fastapi import APIRouter

from pydantic_schemas.user_login import UserLogin

router = APIRouter()
#----------------------------------route_1----------------------------------------#
@router.post('/signup', status_code = 201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):

    # check if user already exists in db
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        # return 'User with this email already exists!' RETURNING SO, WILL RETURN 200 OK STATUS (not appropriate)
        raise HTTPException(400 ,'User with the same email already exists!')
    
    # if not exists, add user in db
    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt(16))

    user_db = User(id = str(uuid.uuid4()), name = user.name, email = user.email, password = hashed_pw) 
    db.add(user_db)
    db.commit()
    db.refresh(user_db)
    return user_db

#----------------------------------route_2----------------------------------------#
@router.post('/login')
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    #check if a user with same email already exists
    user_db = db.query(User).filter(User.email == user.email).first()

    if not user_db:
        raise HTTPException(400, "User with this email does not exist!")
    
    #password matching or not
    is_match = bcrypt.checkpw(user.password.encode(), user_db.password)

    if not is_match:
       raise HTTPException(400, "Incorrect password!")
        
    #JWT
    token = jwt.encode({'id': user_db.id}, 'password_key')

    return {'token' : token, 'user' : user_db}    

#----------------------------------route_2----------------------------------------#
@router.get('/')
def current_user_data(db: Session = Depends(get_db), user_dict = Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['uid']).options(
        joinedload(User.favourites),
    ).first()
    
    if not user:
        raise HTTPException(404, "User not found!")
    
    return user    