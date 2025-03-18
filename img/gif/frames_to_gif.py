import os
import sys
import subprocess

from PIL import Image

def generate_gif_from_png(input_pattern, output_gif, fps=24, transparency_color="ffffff"):
    command = [
        'ffmpeg',
        '-pattern_type', 'glob',
        '-i', input_pattern,
        '-vf', f'fps={fps},split[s0][s1];[s0]palettegen=reserve_transparent=on:transparency_color={transparency_color}[s2];[s1][s2]paletteuse',
        '-loop', '0',
        output_gif
    ]
    subprocess.run(command, check=True)


def create_gif(image_folder, output_gif_path, image_pattern="frame_{:02d}.png",
               duration_ms=100):
    """
    Creates a GIF from a sequence of images.

    :param image_folder: Path to the folder containing the images.
    :param output_gif_path: Output path for the generated GIF.
    :param image_pattern: Filename pattern for the images. Default is 'frame_%02d.png'.
    :param start: Starting index of the images (inclusive).
    :param end: Ending index of the images (inclusive).
    """
    # List to hold all image frames
    frames = []

    # Loop through the range of indices and append each image to the frames list
    max_frames = 1000
    for i in range(1, max_frames):
        filename = image_pattern.format(i)
        file_path = os.path.join(image_folder, filename)
        try:
            img = Image.open(file_path)
            frames.append(img.copy())
            print(f"Appended {file_path}")
        except IOError:
            print(f"Error opening {file_path}")
            break

    # Save the frames as a GIF
    if frames:
        # duration: duration of each frame in ms
        frames[0].save(output_gif_path, format='GIF', append_images=frames[1:],
                       save_all=True, duration=duration_ms, loop=0)
        print(f"GIF saved at {output_gif_path}")
    else:
        print("No images were found or processed.")


def main():
    image_folder = sys.argv[1]  # Folder containing your images
    duration_ms = int(sys.argv[2])  # Folder containing your images
    output_gif_path = "./output.gif"  # Desired output GIF path

    create_gif(image_folder, output_gif_path, image_pattern="{:02d}.png",
               duration_ms=duration_ms)

    # Example usage
    input_pattern = f"{image_folder}/*.png"
    fps = 1000 / duration_ms
    generate_gif_from_png(input_pattern, output_gif_path, fps)
    print(f"Generated gif: {output_gif_path}")


if __name__ == '__main__':
    main()
