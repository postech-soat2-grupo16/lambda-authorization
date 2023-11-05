import json
import os
import jwt
import boto3

def main(event, context):
    response = {
        "statusCode": 403,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Unauthorized: Missing or invalid authentication credentials."
        })
    }
    if 'body' in event:
        request_body = json.loads(event['body'])
        if 'token' in request_body:
            cpf = request_body['token']
            is_token_ok = token_validation(cpf)
            if is_token_ok:
                response = {
                    "statusCode": 200,
                    "headers": {
                        "Content-Type": "application/json"
                    },
                    "body": json.dumps({
                        "token": "OK"
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
        decoded = jwt.decode(encoded, key, algorithms="HS256")
        print("token decoded", decoded)
        return true
    except Exception as e:
        print("Error! ", e)
        sys.exit(1)