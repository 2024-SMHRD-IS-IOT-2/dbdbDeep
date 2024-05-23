import RPi.GPIO as gpio
import threading

PIN_LIVING = 17
PIN_BED = 18
PIN_FAN = 21
PIN_BATH = 27

gpio.setmode(gpio.BCM)
gpio.setup(PIN_BED, gpio.OUT)   ## bedrooms
gpio.setup(PIN_LIVING, gpio.OUT)  ## livingroom
gpio.setup(PIN_FAN, gpio.OUT) ## fan
gpio.setup(PIN_BATH, gpio.OUT)

p1 = gpio.PWM(PIN_LIVING, 500)  ## livingroom
p1.start(0)
p2 = gpio.PWM(PIN_BED, 500)  ## bedroom
p2.start(0)
p3 = gpio.PWM(PIN_BATH, 500)  ## bathroom
p3.start(0)

BRIGHT_LIVING = 0
BRIGHT_BED = 0
BRIGHT_BATH = 0
POWER_FAN = 0


def ctrlThread(loc, power,sec) :
    thread = threading.Timer(sec, control, args=(loc,power))
    thread.start()
    thread.join()
    res = f"{loc} 위치에 전원 {power} IoT 조작 완료"
    
    return res

def control(loc, power) :
    global BRIGHT_LIVING
    global BRIGHT_BED
    global POWER_FAN
    
    if loc == 0 :
        gpio.output(PIN_FAN, power)
        POWER_FAN = 0
        

    if loc == 1 :

        p1.ChangeDutyCycle(power)
        BRIGHT_LIVING = power

    elif loc == 2:

        p2.ChangeDutyCycle(power)
        BRIGHT_BED = power
        
    elif loc == 3:

        p3.ChangeDutyCycle(power)
        BRIGHT_BATH = power
    
    
    

def curStatus():
    
    return {
            'FAN':POWER_FAN,
            'BED':BRIGHT_BED,
            'LIVING':BRIGHT_LIVING,
            'BATH':BRIGHT_BATH
            }

