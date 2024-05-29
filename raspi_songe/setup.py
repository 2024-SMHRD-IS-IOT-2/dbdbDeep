import subprocess, sys

def inst_all_from_requirements(requirement_file):
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", requirement_file])
    
    
## 라즈베리파이에 sudo apt-get install 해야되는 것들
## flac
## libportaudio2


### 오디오 버벅거리는 문제
# https://forums.raspberrypi.com/viewtopic.php?t=333335
# 오류메세지
# ALSA lib pcm.c:8545:(snd_pcm_recover) underrun occurred


### EXTERNALLY-MANAGED 해결방법
# sudo rm /usr/lib/python3.11/EXTERNALLY-MANAGED

## pip install 시 에러 wheels for h5py 어쩌구
# sudo apt install python3-dev libhdf5-dev
# sudo apt install python3-h5py
# 후 다시 설치


## https://blog.naver.com/finway/221237740617
## https://github.com/tensorflow/tensorflow/issues/8037