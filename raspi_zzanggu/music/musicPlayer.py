from spotipy import Spotify
from spotipy.oauth2 import SpotifyOAuth
from spotipy.oauth2 import SpotifyClientCredentials
from enum import Enum
import webbrowser


class MUSIC_CTRL(Enum):
    STOP = 0
    PAUSE = 1
    PLAY = 2
    SKIP = 3
    CUR_MUSIC_INFO = 4
    RECOMMEND_NOW = 5
    DONT_RECOMMEND = 6
    
class MusicPlayer() :
    def __init__(self,SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, SPOTIFY_URI):
        self.sp = Spotify(auth_manager=SpotifyOAuth(
            client_id=SPOTIFY_CLIENT_ID,
            client_secret=SPOTIFY_CLIENT_SECRET,
            redirect_uri=SPOTIFY_URI,
            scope="user-modify-playback-state user-read-playback-state"
        ))
        webbrowser.open_new('https://open.spotify.com/')
        
        
    
            
    def skip(self):
        timer = self.sp.current_user_playing_track()
        time = timer['progress_ms'] / 1000
        self.sp.next_track()
        return time
    def play(self,title):
        music_title = [title[0]['music'][i]['title'] for i in range(len(title[0]))]
        play_track = [self.sp.search(i,limit=1,type='track')['tracks']['items'][0]['uri'] for i in music_title]    
        recommend_data = self.sp.recommendations(seed_tracks=play_track,limit=10)
        play_tracks = [recommend_data['tracks'][i]['external_urls']['spotify'] for i in range(len(recommend_data['tracks']))]
        
        devices = self.sp.devices()
        device_id = None
        if devices['devices']:
            device_id = devices['devices'][0]['id']
        self.sp.start_playback(device_id=device_id,uris = play_tracks)
        
    def pause(self):
        self.sp.pause_playback()
    def stop(self):
        self.sp.pause_playback()
    def get_info(self):
        info = self.sp.current_user_playing_track()
        artist = info['item']['artists'][0]['name']
        title = info['item']['name']
        return artist, title
    
    