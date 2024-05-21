import os
import sys
import codecs


def convert_unicode_escape_to_utf8(input_path, output_path):
    # opens a file and converts input to true Unicode
    with codecs.open(input_path, "rb", "unicode_escape") as tmp_f:
        contents = tmp_f.read()
        # type(contents) = unicode

    # opens a file with UTF-8 encoding
    with codecs.open(output_path, "wb", "utf8") as tmp_f:
        tmp_f.write(contents)
    print(f'Wrote file {output_path}')


def main():
    input_path = sys.argv[1]
    dirname = os.path.dirname(input_path)
    base, ext = os.path.splitext(os.path.basename(input_path))
    output_path = os.path.join(dirname, f'{base}_utf8{ext}')
    convert_unicode_escape_to_utf8(input_path, output_path)


if __name__ == '__main__':
    main()
