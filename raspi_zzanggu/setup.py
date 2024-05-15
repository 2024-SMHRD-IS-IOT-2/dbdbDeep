import subprocess, sys
import sounddevice as sd
from pvrecorder import PvRecorder

def inst_all_from_requirements(requirement_file):
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", requirement_file])
    
    
## 마이크 인덱스 확인하기
for i, device in enumerate(PvRecorder.get_available_devices()):
    print('Device %d: %s' % (i, device))
    if ("마이크" in device) or "MAONO" in device :
        
        print(f"mic at index {i} detected")
    else : 

        print(f"mic not detected")

## 스피커 찾기
# device_list = sd.query_devices()
# print(device_list)
