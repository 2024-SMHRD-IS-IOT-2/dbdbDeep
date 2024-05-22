import wave
import struct
import numpy as np
import time
from pvrecorder import PvRecorder
import pvporcupine
import argparse
import os
import speech_recognition as sr


class InputHandler:
    def __init__(self, access_key, keyword_file_path, model_file_path, sensitivity):
        self.PORCU_ACCESS_KEY = access_key
        self.PORCU_KEYWORD_FILE_PATH = keyword_file_path
        self.PORCU_MODEL_FILE_PATH = model_file_path
        self.PORCU_SENSITIVITY = sensitivity
        self.DEVICE_INDEX = -1

        for i, device in enumerate(PvRecorder.get_available_devices()):
            print('Device %d: %s' % (i, device))
            if "MAONO" in device :
                self.DEVICE_INDEX = i
                print(f"mic at index {i} detected")
                break
            


    
    ## 키워드 인식
    def recognize_keyword(self):
        parser = argparse.ArgumentParser()

        parser.add_argument(
            '--access_key',
            help='AccessKey obtained from Picovoice Console (https://console.picovoice.ai/)')

        parser.add_argument(
            '--keywords',
            nargs='+',
            help='List of default keywords for detection. Available keywords: %s' % ', '.join(
                '%s' % w for w in sorted(pvporcupine.KEYWORDS)),
            choices=sorted(pvporcupine.KEYWORDS),
            metavar='')

        parser.add_argument(
            '--keyword_paths',
            nargs='+',
            help="Absolute paths to keyword model files. If not set it will be populated from `--keywords` argument")

        parser.add_argument(
            '--library_path',
            help='Absolute path to dynamic library. Default: using the library provided by `pvporcupine`')

        parser.add_argument(
            '--model_path',
            help='Absolute path to the file containing model parameters. '
                'Default: using the library provided by `pvporcupine`')

        parser.add_argument(
            '--sensitivities',
            nargs='+',
            help="Sensitivities for detecting keywords. Each value should be a number within [0, 1]. A higher "
                "sensitivity results in fewer misses at the cost of increasing the false alarm rate. If not set 0.5 "
                "will be used.",
            type=float,
            default=None)

        parser.add_argument('--audio_device_index', help='Index of input audio device.', type=int, default=-1)

        parser.add_argument('--output_path', help='Absolute path to recorded audio for debugging.', default=None)

        parser.add_argument('--show_audio_devices', action='store_true')

        
        args = parser.parse_args(['--access_key', self.PORCU_ACCESS_KEY, 
                                  '--keyword_paths', self.PORCU_KEYWORD_FILE_PATH, 
                                  '--model_path', self.PORCU_MODEL_FILE_PATH])

        if args.show_audio_devices:
            for i, device in enumerate(PvRecorder.get_available_devices()):
                print('Device %d: %s' % (i, device))
            return

        if args.keyword_paths is None:
            if args.keywords is None:
                raise ValueError("Either `--keywords` or `--keyword_paths` must be set.")

            keyword_paths = [pvporcupine.KEYWORD_PATHS[x] for x in args.keywords]
        else:
            keyword_paths = args.keyword_paths

        if args.sensitivities is None:
            args.sensitivities = [self.PORCU_SENSITIVITY] * len(keyword_paths)

        if len(keyword_paths) != len(args.sensitivities):
            raise ValueError('Number of keywords does not match the number of sensitivities.')

        try:
            porcupine = pvporcupine.create(
                access_key=args.access_key,
                library_path=args.library_path,
                model_path=args.model_path,
                keyword_paths=keyword_paths,
                sensitivities=args.sensitivities)
            
            
        except pvporcupine.PorcupineInvalidArgumentError as e:
            print("One or more arguments provided to Porcupine is invalid: ", args)
            print(e)
            raise e
        except pvporcupine.PorcupineActivationError as e:
            print("AccessKey activation error")
            raise e
        except pvporcupine.PorcupineActivationLimitError as e:
            print("AccessKey '%s' has reached it's temporary device limit" % args.access_key)
            raise e
        except pvporcupine.PorcupineActivationRefusedError as e:
            print("AccessKey '%s' refused" % args.access_key)
            raise e
        except pvporcupine.PorcupineActivationThrottledError as e:
            print("AccessKey '%s' has been throttled" % args.access_key)
            raise e
        except pvporcupine.PorcupineError as e:
            print("Failed to initialize Porcupine")
            raise e

        keywords = list()
        for x in keyword_paths:
            keyword_phrase_part = os.path.basename(x).replace('.ppn', '').split('_')
            if len(keyword_phrase_part) > 6:
                keywords.append(' '.join(keyword_phrase_part[0:-6]))
            else:
                keywords.append(keyword_phrase_part[0])

        recorder = PvRecorder(
            frame_length=porcupine.frame_length,
            # device_index=args.audio_device_index
            device_index = self.DEVICE_INDEX
            
            )
        self.DEVICE_INDEX = args.audio_device_index
        recorder.start()

        wav_file = None
        if args.output_path is not None:
            wav_file = wave.open(args.output_path, "w")
            wav_file.setnchannels(1)
            wav_file.setsampwidth(2)
            wav_file.setframerate(16000)

        print('Listening ...')

        try:
            while True:
                pcm = recorder.read()
                result = porcupine.process(pcm)

                if wav_file is not None:
                    wav_file.writeframes(struct.pack("h" * len(pcm), *pcm))

                if result >= 0:
                    print(' %s Detected' % (keywords[result]))

                    return True

        except KeyboardInterrupt:
            print('Stopping ...')
        finally:
            recorder.delete()
            porcupine.delete()
            if wav_file is not None:
                wav_file.close()
            pass


    ## 사용자 음성 받음
    def get_user_input(self, filename, inputWaitTime=10, silence_duration=2, silence_threshold=5000):
        text, audio = "", ""
        
        recorder = PvRecorder(device_index=self.DEVICE_INDEX, frame_length=512)
        audio = []
        
        silenceDur = silence_duration
        silenceThr = silence_threshold
        silenceStart = 0
        silenceEnd = 0
        isTalking = False
        
        try:
            recorder.start()
            silenceStart = time.time() + inputWaitTime
            print("talking : receiving user Input...")

            while True:
                frame = recorder.read()
                frameChk = np.mean(abs(np.array(frame)))
                
                audio.extend(frame)
                # 현재 시간
                silenceEnd = time.time()

                ## 문장 시작 체크
                if not isTalking and frameChk > silenceThr :
                    print("talking : user talking start")
                    isTalking = True
                    silenceStart = time.time()
                ## 이야기중임. 
                elif isTalking and (frameChk > silenceThr)  :
                    silenceStart = time.time()


                ## 문장 끝나고 silenceDur 만큼 조용함.
                if silenceEnd-silenceStart >= silenceDur and isTalking:
                    print(f"talking : silence for {silenceDur} sec. end Sentence recording")
                    break
                ## 주어진 시간동안 인풋 안받음.
                elif silenceEnd-silenceStart >= 0 and not isTalking:
                    print(f"user input not detected for {inputWaitTime} sec. back to Triggering")
                    return False, "", ""

            ## wav 파일로 사용자 음성 저장
            recorder.stop()
            with wave.open(filename, 'w') as f:
                f.setparams((1, 2, 16000, 512, "NONE", "NONE"))
                f.writeframes(struct.pack("h" * len(audio), *audio))
                
            ## wav 파일 문자열로.
            r = sr.Recognizer()
            try :
                audioFile = sr.AudioFile(filename)
                with audioFile as source :
                    audio = r.record(source)
                userInputString = r.recognize_google(audio, language='ko-KR')
                return True, userInputString, filename
            except Exception as e :
                print("error1 = ", e)
                
                
        except Exception as e:
            print("error2 =", e)
        finally:
            recorder.delete()
        
        return False, "", ""
