#importing base64 module
import os
import sys
import base64


def main():
    fn_base64 = sys.argv[1]
    #open file with base64 string data
    with open(fn_base64, 'rb') as tmp_f:
        encoded_data = tmp_f.read()
        tmp_f.close()
    #decode base64 string data
    decoded_data = base64.b64decode((encoded_data))
    #write the decoded data back to original format in  file
    base = os.path.splitext(os.path.basename(fn_base64))[0]
    fn_output = os.path.join(os.path.dirname(fn_base64),
                             f'{base}.jpg')
    with open(fn_output, 'wb') as tmp_f:
        tmp_f.write(decoded_data)
        tmp_f.close()
    print(f'Converted base64 file {fn_base64} into {fn_output}')


if __name__ == '__main__':
    main()
