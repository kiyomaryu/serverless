import json
import os
import requests

def lambda_handler(event, context):
    
    headers = {
       'Accept': 'application/json',
       'Authorization': os.environ['API_KEY'],
       'Content-Type': 'application/json',
       'charset': 'utf8'
    }
    response = requests.get('https://api.switch-bot.com/v1.0/devices/' + os.environ['DEVICE_ID'] +'/status', headers=headers)
    #print(response.text)
    json_data = response.json()
    return json_data['body']['voltage']*json_data['body']['electricCurrent']
