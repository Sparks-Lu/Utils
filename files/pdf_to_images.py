import os
import sys

"""
sudo apt install poppler-utils
pip install pdf2image
"""

from pdf2image import convert_from_path


def convert_pdf_to_imgs(pdf_path):
    images = convert_from_path(pdf_path)
    output_folder = os.path.dirname(pdf_path)
    bname = os.path.splitext(os.path.basename(pdf_path))[0]
    for i, image in enumerate(images):
        output_path = os.path.join(output_folder, f'from_pdf_{bname}_{i}.jpg')
        image.save(output_path)
    print(f'Converted {len(images)} pages to JPG images.')


def main():
    pdf_path = sys.argv[1]
    convert_pdf_to_imgs(pdf_path)


if __name__ == '__main__':
    main()
