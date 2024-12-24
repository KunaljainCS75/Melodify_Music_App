import os
import uuid
import cloudinary
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session, joinedload
from database import get_db

import cloudinary.uploader, cloudinary.api

from middleware.auth_middleware import auth_middleware
from models.favourite import Favourite
from models.song import Song
from pydantic_schemas.delete_song import DeleteSong
from pydantic_schemas.favourite_song import FavouriteSong

router = APIRouter()

# Configuration       
cloudinary.config( 
    cloud_name = "djgxnb28l", 
    api_key = os.getenv("API_KEY"), 
    api_secret = os.getenv("API_SECRET_KEY"), # Click 'View API Keys' above to copy your API secret
    secure = True
)

# Upload Song 
@router.post('/upload', status_code = 201)
def upload_song(song: UploadFile = File(...), 
                thumbnail: UploadFile = File(...), 
                artist: str = Form(...), 
                song_name: str = Form(...),
                hex_code: str = Form(...),
                db: Session = Depends(get_db),
                auth_dict = Depends(auth_middleware)
                ): # ... = required paramter
    # upload the actual file in Cloudinary (external) storage
    song_id = str(uuid.uuid4())
    song_res = cloudinary.uploader.upload(song.file, resource_type = 'auto', folder = f'songs/{song_id}')
    # print(song_res['url'])
    thumbnail_res = cloudinary.uploader.upload(thumbnail.file, resource_type = 'image', folder = f'songs/{song_id}')
    # print(thumbnail_res['url'])
    
    # upload the urls in postgreSQL 
    new_song = Song(
        id = song_id,
        song_name = song_name,
        artist = artist,
        hex_code = hex_code,
        song_url = song_res['url'],
        thumbnail_url = thumbnail_res['url']
    )
    
    db.add(new_song)
    db.commit()
    db.refresh(new_song)
    
    return new_song

# Get all user songs
@router.get('/list')
def list_songs(db: Session = Depends(get_db), auth_dict = Depends(auth_middleware)):
    songs = db.query(Song).all()
    return songs

# Mark/Unmark Favourite
@router.post('/favourite')
def favourite_song(song: FavouriteSong, 
                   db: Session = Depends(get_db), 
                   auth_dict = Depends(auth_middleware)):

    # if a song is already favourite for a user and else case
    user_id = auth_dict['uid']
    fav_song = db.query(Favourite).filter(Favourite.song_id == song.song_id, Favourite.user_id == user_id).first()
    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message' : False}
    else:
        new_fav = Favourite(id=str(uuid.uuid4()), song_id = song.song_id, user_id = user_id)
        db.add(new_fav)
        db.commit()
        return {'message' : True}


# Get all favourite songs
@router.get('/list/favourites')
def list_fav_songs(db: Session = Depends(get_db), auth_dict = Depends(auth_middleware)):
    user_id = auth_dict['uid']
    fav_songs = db.query(Favourite).filter(Favourite.user_id == user_id).options(
        joinedload(Favourite.song),
        joinedload(Favourite.user)
    ).all()
    return fav_songs


@router.delete('/delete', status_code = 204)
def delete_song(song: DeleteSong,
                db: Session = Depends(get_db),
                auth_dict = Depends(auth_middleware)):
   
    delete_song = db.query(Song).filter(Song.id == song.song_id).first()
    
    if not delete_song:
        raise HTTPException(204, "Deletion unsuccessful, song not found!")
    
    try:
        user_id = auth_dict['uid']
        fav_song = db.query(Favourite).filter(Favourite.song_id == song.song_id, Favourite.user_id == user_id).first()
        if fav_song:
            db.delete(fav_song)
            db.commit()
        # Delete the entire folder from Cloudinary
        res = cloudinary.api.delete_resources_by_prefix(f'songs/{delete_song.id}', resource_type = 'image')
        res = cloudinary.api.delete_resources_by_prefix(f'songs/{delete_song.id}', resource_type = 'video')
        # print(res)
        cloudinary.api.delete_folder(f'songs/{delete_song.id}')
        
        # Delete the song record from the database
        db.delete(delete_song)
        db.commit()
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting song: {str(e)}")
    
    return {"message": "Song deleted successfully"}    