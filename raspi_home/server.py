from flask import Flask, request
import iotcontrol 

app = Flask(__name__)

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

@app.route('/homestat')
def homestat():
    print("led status")
    
    return lightcontrol.curStatus()


if __name__ == "__main__" :   ## 얘를 직접 실행시켰을때만 실행해라.
    app.run(host="210.183.87.121", port=5000)