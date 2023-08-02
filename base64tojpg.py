#importing base64 module
import base64


def main():
    import sys
    fn_base64 = sys.argv[1]
    #open file with base64 string data
    with open(fn_base64, 'rb') as f:
        encoded_data = f.read()
        f.close()
    #decode base64 string data
    decoded_data = base64.b64decode((encoded_data))
    #write the decoded data back to original format in  file
    import os
    fn_output = os.path.join(os.path.dirname(fn_base64), 'image.jpg')
    with open(fn_output, 'wb') as f:
        f.write(decoded_data)
        f.close()
    print(f'Converted base64 file {fn_base64} into {fn_output}')


if __name__ == '__main__':
    main()
