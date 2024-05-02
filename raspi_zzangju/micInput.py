## import, variables, 
import queue, threading
import sounddevice as sd
import soundfile as sf
import time
import numpy as np
from scipy.io.wavfile import write
import speech_recognition as sr

# Initialize the Recognizer
r = sr.Recognizer()
q = queue.Queue()

silenceStart = 0
silenceEnd = 0
silenceDur = 2
silenceThr = 10

sentenceDoneEvent = threading.Event()
## global 
recorder = False
recording = False


def trigCheckFile():
    with sf.SoundFile("./trigCheck.wav", mode='w', samplerate=16000, subtype='PCM_16', channels=1) as file:
        with sd.InputStream(samplerate=16000, dtype='int16', channels=1, callback=micSave):
            while recording:
                file.write(q.get())
        
def micSave(indata, frames, time, status):
    q.put(indata.copy())  

def checkingTrigger(name) :
    while True :
        global recording
        global recorder
        
        recording = True
        recorder = threading.Thread(target=trigCheckFile )
        print('trigcheck : start recording')
        recorder.start()

        time.sleep(3)

        recording = False
        recorder.join()
        print('trigcheck : stop recording')

        audioFile = sr.AudioFile('./trigCheck.wav')
        try :
            with audioFile as source :
                audio = r.record(source)

            print("recognizing...")
            recognized = r.recognize_google(audio, language='ko-KR')
            print(recognized)

            if name in recognized :
                print("trigcheck : 이름 트리거")
                return True
        except :
            print("trigcheck : no input")
        return False



def inputUserSentence():
    global recording
    global silenceStart
    global silenceEnd
    isTalking = False
    
    
    with sf.SoundFile("./sentence.wav", mode='w', samplerate=16000, subtype='PCM_16', channels=1) as file:
        with sd.InputStream(samplerate=16000, dtype='int16', channels=1, callback=micSave):
            print("getting Sentence")

            while recording :
                audio_data = q.get()
                file.write(audio_data)

                ## 소리 볼륨 한계치 20 아래면 silence
                ams = np.sqrt(np.mean(abs(audio_data)))
                # 현재 시간
                silenceEnd = time.time()
                
                ## 문장 시작
                if not isTalking and ams > silenceThr :
                    print("sentence : sentence start")
                    isTalking = True
                    silenceStart = time.time()
                    
                ## 이야기중임. 
                elif ams > silenceThr  and isTalking :
                    silenceStart = time.time()
                    print("sentence : startTime updated")
                
                ## 문장 끝나고 dur 만큼 조용함.
                ## 
                if silenceEnd - silenceStart >= silenceDur and isTalking:
                    print(f"sentence : silence for {silenceDur} sec. end Sentence recording")
                    recording = False
                    sentenceDoneEvent.set()
                    return 
                    
                
def getSentence():
    global recorder
    global recording
    userSentence = ""
    
    recording = True
    recorder = threading.Thread(target=inputUserSentence)
    print('sentence : getSentence start recording')
    recorder.start()
    
    sentenceDoneEvent.wait()
    
    print("before audioFile")
    time.sleep(0.05)
    audioFile = sr.AudioFile('./sentence.wav')
    try :
        with audioFile as source :
            audio = r.record(source)

        print("wav convert to String...")
        userSentence = r.recognize_google(audio, language='ko-KR')
        print(userSentence)
        
    except Exception as e:
        print("sentenceError :", e)
        
    sentenceDoneEvent.clear()
    
    return userSentence
    



