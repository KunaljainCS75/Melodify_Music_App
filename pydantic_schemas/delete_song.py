from pydantic import BaseModel


class DeleteSong(BaseModel):
    song_id: str