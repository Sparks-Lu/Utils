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


def main():
    access_key = sys.argv[1]
    access_secret = sys.argv[2]
    expire_seconds = int(sys.argv[3])
    authorization = encode_jwt_token(access_key, access_secret, expire_seconds)
    print(authorization)


if __name__ == '__main__':
    main()
