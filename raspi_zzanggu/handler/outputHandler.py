from common.process import MyProcess, PROCESS_STATUS
import os
import requests 
import time
import sounddevice as sd
import soundfile as sf
import serial
import asyncio, aiohttp
import logging

## typecast TTS 오디오 생성 쓰레드
## 인풋 큐 : flag, emotion, text
## 아웃풋 큐 : flag, emo, filename
class GenerateOutputAudioProcess(MyProcess):
    def __init__(self, actor_id, api_key, run_async=False):
        if run_async == True :
            target = self.async_run
        else : 
            target = self.target
        super().__init__(target=target)

        self.ACTOR_ID = actor_id
        self.API_KEY = api_key
        self.cnt = 0


    ## 비동기 함수
    def async_run(self, ev):
        asyncio.run(self.async_target(ev))

    ### 비동기  
    async def async_target(self, ev):
        self.session = aiohttp.ClientSession()
        while True:
            # ev.wait()
            if not self.input_queue.empty():
                data = self.input_queue.get_nowait()
                if len(data) == 4:
                    startTime, flag, emo, text = data
                else:
                    flag, emo, text = data
                self.set_status(flag)
                if flag == PROCESS_STATUS.FINISH:
                    break

                # 대화 종료시 파일카운터 초기화
                elif flag == PROCESS_STATUS.DONE:
                    self.cnt = 0
                    logging.info("TTSgen: TTS create done")
                    self.push_output(flag, "", "")
                    # ev.wait()

                ## TTS 작업
                elif flag == PROCESS_STATUS.RUNNING:
                    filename = f"./wav/ttsOut{self.cnt}.wav"
                    ## TEST : 미리 생성돼있는 넘들로 대신 출력
                    # time.sleep(1) ## TEST tts 생성 딜레이
                    # startTime = time.time()
                    status = await self.do_async_tts(text, filename, emo)
                    endTime = time.time()
                    logging.error(f"TIME TTS : {(endTime-startTime):.2f} second")
                    
                    if status == True :
                        logging.info(f"TTSgen: tts file created : {filename}")
                        self.push_output(flag, emo, filename)
                        self.cnt += 1

    ## 비동기 tts 
    async def do_async_tts(self, text, filename, emotion="normal-1", lang="ko"):
        HEADERS = {"Authorization": f"Bearer {self.API_KEY}"}
        # request speech synthesis
        # async with aiohttp.ClientSession() as session:
        async with self.session.post(
            "https://typecast.ai/api/speak",
            headers=HEADERS,
            json={
                "text": text,
                "lang": lang,
                "actor_id": self.ACTOR_ID,
                "xapi_hd": True,
                "model_version": "latest",
                "emotion_tone_preset": emotion,
            },
        ) as r:
            if r.status == 200:  # 요청 성공
                speak_url = (await r.json())["result"]["speak_v2_url"]
            else:  # 요청 실패
                logging.error("실패 상태 코드:", r.status)
                return False

        # polling the speech synthesis result
        audio_url = ""
        # async with aiohttp.ClientSession() as session:
        for _ in range(120):
            async with self.session.get(speak_url, headers=HEADERS) as r:
                ret = (await r.json())["result"]
                if ret["status"] == "done":
                    audio_url = ret["audio_download_url"]
                    break

        if audio_url != "":
                # async with aiohttp.ClientSession() as session:
            async with self.session.get(audio_url) as r:
                with open(filename, "wb") as f:
                    f.write(await r.content.read())
        else:
            raise Exception(f"""Typecast API request failed with {ret["status"]}""")

        return True

    # # 동기 프로세스 함수
    def target(self, ev):
        while True:
            # ev.wait()
            if not self.input_queue.empty():
                data = self.input_queue.get_nowait()
                if len(data) == 4:
                    startTime, flag, emo, text = data
                else:
                    flag, emo, text = data

                self.set_status(flag)
                if flag == PROCESS_STATUS.FINISH:
                    break
                
                # 대화 종료시 파일카운터 초기화
                elif flag == PROCESS_STATUS.DONE :
                    self.cnt = 0
                    print("TTSgen: TTS create done")
                    self.push_output(flag, "", "")
                    ev.wait()
                
                ## TTS 작업
                elif flag == PROCESS_STATUS.RUNNING :
                    filename = f"./wav/ttsOut{self.cnt}.wav"
                    ## TEST : 미리 생성돼있는 넘들로 대신 출력
                    # time.sleep(1) ## TEST tts 생성 딜레이 
                    self.do_tts(text,filename,emo)
                    endTime = time.time()
                    print(f"TIME TTS : {(endTime-startTime):.2f} second")
                    print("TTSgen: tts file created : ", filename)
                    self.push_output(flag, emo, filename)
                    
                    self.cnt+=1
        
    # ### 동기 tts 처리함수
    def do_tts(self, text, filename, emotion='normal-1', lang='ko'):
        HEADERS = {'Authorization': f'Bearer {self.API_KEY}'}
        # request speech synthesis
        r = requests.post('https://typecast.ai/api/speak', headers=HEADERS, json={
            'text': text,
            'lang': lang,
            'actor_id': self.ACTOR_ID,
            'xapi_hd': True,
            'model_version': 'latest',
            "emotion_tone_preset": emotion
        })
        speak_url = r.json()['result']['speak_v2_url']
        
        # polling the speech synthesis result
        for _ in range(120):
            r = requests.get(speak_url, headers=HEADERS)
            ret = r.json()['result']
            # audio is ready
            if ret['status'] == 'done':
                # download audio file
                r = requests.get(ret['audio_download_url'])
                with open(filename, 'wb') as f:
                    f.write(r.content)
                break
            else :
                print("TTSgen: wait 0.1sec. processing tts")
                time.sleep(0.1)

                    

## 음성 출력 대기 클래스
## 대화로 분류될 시 출력
class PlayAudio:
    def __init__(self, input_q, serL:serial, serR:serial):
        self.input_queue = input_q
        self.serL = serL
        self.serR = serR

    # 인풋 큐 클리어 함수 (대화가 아닐 시)
    def clear_input(self):
        while True:
            if not self.input_queue.empty() :
                flag, _, filename = self.input_queue.get_nowait()
                if flag == PROCESS_STATUS.FINISH or flag == PROCESS_STATUS.DONE :
                    break
                try :
                    logging.error("PlayAudio: remove file:", filename)
                    os.remove(filename)
                except FileNotFoundError:
                    logging.error("PlayAudio: 해당 파일을 찾을 수 없음.", filename)


    def play_all_conv_file(self):
        while True:
            if not self.input_queue.empty():
                flag, emo, filename = self.input_queue.get_nowait()
                logging.info("playAllConv: ",flag, emo, filename)
                if flag == PROCESS_STATUS.FINISH:
                    break
                elif flag == PROCESS_STATUS.DONE :
                    logging.info("PlayAudio: all audio played")
                    break
                
                elif flag == PROCESS_STATUS.RUNNING :
                    data, fs = sf.read(filename, dtype='float32')  
                    time.sleep(0.2) ## 문장 사이사이 숨쉴 틈을..
                    self.serL.write(emo.encode())
                    self.serR.write(emo.encode())

                    logging.info("PlayAudio: play conv audio ", filename)
                    sd.play(data, fs)
                    status = sd.wait()  # Wait until file is done playing
                    os.remove(filename) # remove file after playing
                    logging.error("removefile:", filename)


    ## 사전 대답 파일 출력 
    def play_file(self, filename):
        data, fs = sf.read(filename, dtype='float32')  

        logging.error("PlayAudio: play sound ", filename)
        sd.play(data, fs)
        status = sd.wait()  # Wait until file is done playing
        time.sleep(0.3) ## 문장 사이사이 숨쉴 틈을..
                    


class HomeCtrl:
    def __init__(self, addr) :
        self.addr = addr

    def requestCtrl(self, args) :
        url = f"{self.addr}/homectrl"
        
        try:
            r = requests.get(url=url, params=args)
            if r.status_code == 200 :
                logging.info("HomeCtrl: 통신 성공")
                return r.status_code
            else :
                logging.error('HomeCtrl: 통신 실패')
                return r.status_code
        except:
            logging.error('HomeCtrl: request 오류')
            return(500)
            


