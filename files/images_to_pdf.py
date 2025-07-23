import os
import sys

from PIL import Image
import os


def convert_imgs_to_pdf(path):
    # List of image file paths (must be in order)
    fns = os.listdir(path)
    img_fns = []
    for fname in fns:
        ext = os.path.splitext(fname)[-1]
        full_path = os.path.join(path, fname)
        if os.path.isfile(full_path) and ext.lower() in ('.png', '.jpg', '.jpeg'):
            img_fns.append(full_path)
    img_fns = sorted(img_fns)
    print(f'Input images: {img_fns}')
    # Output PDF file
    output_pdf = os.path.join(path, 'output.pdf')

    # Open images and convert to PDF
    images = []
    for img_file in img_fns:
        img = Image.open(img_file)
        if img.mode != 'RGB':
            img = img.convert('RGB')  # PDF requires RGB mode
        images.append(img)
    # Save as PDF (first image is the cover, others are appended)
    images[0].save(output_pdf, save_all=True, append_images=images[1:])
    print(f"Saved PDF to {output_pdf}")


def main():
    path = sys.argv[1]
    convert_imgs_to_pdf(path)


if __name__ == '__main__':
    main()
