from flask import Flask, request
import iotcontrol 

app = Flask(__name__)
emo = ""

@app.route('/')
def hello():
    return 'home'

@app.route('/homectrl', methods=['POST','GET'])
def homectrl():
    print("home control")
    device = int(request.args.get('device'))
    power = int(request.args.get('power'))
    sec = int(request.args.get('sec'))

    
    print(f"sending data... device : {device}, power : {power}, sec : {sec}") 
    result = iotcontrol.ctrlThread(device, power, sec)
    return result
    # return "homectrl"

@app.route('/homestat')
def homestat():
    print("led status")
    # return "homestat"
    return lightcontrol.curStatus()


@app.route('/setEmo', methods=['GET'])
def setEmo():
    global emo
    print("setting emo")
    emo = request.args.get('emotion')
    return f"{emo} success"


@app.route('/getEmo')
def getEmo():
    global emo
    print("getting emo")

    return emo



if __name__ == "__main__" :  
    app.run(host="172.30.1.50", port=5000)