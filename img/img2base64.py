# Import base64 module
import base64


def main():
    import sys
    fn_input = sys.argv[1]
    # Get image file
    b64_str = None
    with open(fn_input, 'rb') as f:
        print(f'Reading image {fn_input}...')
        data = f.read()
        print(f'Readed data: {data}')
        # Convert to base64 string
        b64_str = base64.b64encode(data)
        print(f'base64 string: {b64_str}')

    if b64_str is not None:
        import os
        fn_output = os.path.join(os.path.dirname(fn_input), 'base64.txt')
        with open(fn_output, "wb") as f:
            f.write(b64_str)
        print(f'Image {fn_input} is converted to base64 file {fn_output}')
    else:
        print(f'Error in reading image {fn_input}')


if __name__ == '__main__':
    main()
