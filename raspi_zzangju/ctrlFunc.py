import requests
from config import settings
from langchain_core.tools import tool

def ledctrl(loc, bright, sec):
    url = f"{settings.raspHomeIP}/ledctrl"
    param = {'loc' : loc, 'bright' : bright, 'sec' : sec}
    r = requests.get(url=url, params=param)

    if r.status_code == 200 :
        print('성공')
        return r.content.decode()
    else :
        print('실패')
        
        
def ledStat() :
    url = f"{settings.raspHomeIP}/ledstat"
    r = requests.get(url=url)
    
    if r.status_code == 200 :
        print(r.content.decode())
    else : 
        print("led status 가져오기 실패")

    return r.content.decode()


@tool
def lightControl (loc:int, bright:int, sec:int) -> str :
    """
        create a string in get method format. 
        sending location, light control, and second
        control the brightness 0(off) to 100
        sleep light is at 50 default
        if second is not given, default second is 0
        for loc,
        living-room = 1
        bed-room = 2
    """
    
    return "lightcontrol"


@tool
def musicControl (skip : bool, stop : bool, pause : bool) -> str :
    """
        check if user wants to skip, pause, or stop the music.
    """
    
    return "musicControl"

    
@tool
def scheduling (sqlquery, withWho, where, when, what ) -> str :
    """
        all args in korean
        when should be in yy-MM-dd hh:mm format 
        if things are not decided, like location or what, then return 미정 
    """
    
    return sqlquery

llm_ctrl_list = [lightControl, musicControl, scheduling]