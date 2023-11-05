import json
import os
import jwt
import boto3
import datetime
import sys

def main(event, context):
    response = {
        "statusCode": 403,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "isAuthorized": False,
            "context": {
                "exampleKey": "exampleValue"
            }
        })
    }
    if 'headers' in event:
        print('event:: ', event)
        token = event['headers'].get('x-token')
        print('token: ', token)
        if token:
            is_token_ok = token_validation(token)
            print('is token ok: ', is_token_ok)
            response = {
                "statusCode": 200,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({
                    "isAuthorized": is_token_ok,
                    "context": {
                        "exampleKey": "exampleValue"
                    }
                })
            }
    return response

def get_secrets(secret_name):
    try:
        # Create a Secrets Manager client
        session = boto3.session.Session()
        client = session.client(
            service_name='secretsmanager',
            region_name='us-east-1'
        )
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(get_secret_value_response['SecretString'])    
        return secret
    except Exception as e:
        print("Error! ", e)
        sys.exit(1)

def token_validation(token):
    try:
        secret = get_secrets(os.environ['SECRET_KEY_AUTH'])
        key = secret['secret_key']
        decoded = jwt.decode(token, key, algorithms="HS256")
        print("token decoded", decoded)

        exp_claim = decoded.get('exp') 
        current_time = datetime.datetime.utcnow()

        return current_time < datetime.datetime.fromtimestamp(exp_claim)
    except Exception as e:
        print("Error! ", e)
        sys.exit(1)