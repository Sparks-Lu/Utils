# _*_ coding: utf-8 _*_

# -----------------------------------------------------------
#
# Copyright VhuanTech Corporation. All rights reserved.
#
# -----------------------------------------------------------

import sys
import time
# pip install pyjwt==2.6.0
import jwt


def encode_jwt_token(access_key, access_secret, expire_seconds):
    headers = {
        "alg": "HS256",
        "typ": "JWT"
    }
    payload = {
        "iss": access_key,
        "exp": int(time.time()) + expire_seconds,
        "nbf": int(time.time()) - 5 # effect time, in seconds
    }
    token = jwt.encode(payload, access_secret, headers=headers)
    return token


def decode_jwt_token(token):
    try:
        # 如果你知道密钥和算法，可以传递给 decode 函数以验证签名
        decoded = jwt.decode(token, options={"verify_signature": False})
        print(decoded)
    except jwt.ExpiredSignatureError:
        print("Token has expired")
    except jwt.InvalidTokenError:
        print("Invalid token")


def main():
    msg = 'Please select:\n' \
            '1 encode jwt token\n' \
            '2 decode jwt token\n'
    selected = input(msg)
    if selected is None:
        selected = 1
    else:
        selected = int(selected)
    if selected == 1:
        access_key = input('Input access key: ')
        access_secret = input('Input access secret: ')
        expire_seconds = input('Input expire seconds: ')
        expire_seconds = int(expire_seconds)
        authorization = encode_jwt_token(access_key, access_secret, expire_seconds)
        print(authorization)
    elif selected == 2:
        token = input('Input token to be decoded: ')
        decode_jwt_token(token)


if __name__ == '__main__':
    main()
