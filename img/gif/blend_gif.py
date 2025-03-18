import os
import sys

from PIL import Image, ImageSequence
import numpy as np
import matplotlib.pyplot as plt
import moviepy.editor as mpy
import cv2 as cv


from gif_creation_2 import save_transparent_gif


def blend_with_alpha(frame, overlay, step_idx, total):
    """
    使用给定的 Alpha 值将帧与覆盖图混合。
    :param frame: 单帧图像 (PIL.Image)
    :param overlay: 覆盖图像 (PIL.Image)
    :param ratio: 0~1
    :return: 混合后的帧 (PIL.Image)
    """
    # 将帧和覆盖图转换为 RGBA 模式
    frame = frame.convert("RGBA")
    overlay = overlay.convert("RGBA")

    # 调整覆盖图大小以匹配帧
    overlay = overlay.resize(frame.size)
    alpha = overlay.getchannel('A')

    # 将帧和覆盖图转换为 NumPy 数组
    # frame_np = np.array(frame)
    overlay_np = np.array(overlay)

    # 计算混合因子
    # 51 is current color of texts
    step_size = (255 - 51) / total
    # overlay_np[:, :, :3] = overlay_np[:, :, :3] * factor
    # overlay_np = np.clip(overlay_np, 0, 255).astype(np.uint8)

    # erosion effect
    erosion_level = step_idx / total  # 控制消融程度
    # 随机选择像素位置
    rows, cols = np.where(np.random.rand(*overlay_np.shape[:2]) < erosion_level)
    for row, col in zip(rows, cols):
        # 更改选定像素的颜色
        overlay_np[row, col, :3] = [255, 255, 255]

    # Create a mask where alpha > 0
    '''
    # grow brighter gradually
    alpha = np.array(alpha)
    mask = alpha > 0
    # Apply the mask to the RGB channels and add the specified value
    beta = step_size * step_idx
    print(f"beta: {beta}")
    overlay_np[..., :3][mask] = np.clip(overlay_np[..., :3][mask] + beta, 0, 255)
    '''

    overlay_img = Image.fromarray(overlay_np)
    '''
    plt.imshow(overlay_img)
    plt.title('Overlay image')
    plt.show()
    '''

    blended_image = Image.alpha_composite(frame, overlay_img)
    '''
    plt.imshow(blended_image)
    plt.title('Blended image')
    plt.show()
    '''

    # 创建一个新的 Alpha 通道，基于动态 Alpha 值
    '''
    blended_np = frame_np.copy()
    blended_np[:, :, :] = frame_np[:, :, :] + overlay_np[:, :, :]

    # 创建一个新的 PIL 图像
    blended_image = Image.fromarray(blended_np.astype('uint8'))
    '''

    return blended_image


def process_gif(input_gif_path, overlay_png_path, output_gif_path, duration_ms):
    # 打开GIF文件和PNG覆盖图
    gif = Image.open(input_gif_path)
    overlay = Image.open(overlay_png_path)

    frames = []
    total_frames = gif.n_frames
    print(f"Total {total_frames} frame in {input_gif_path}")

    for i, frame in enumerate(ImageSequence.Iterator(gif)):
        print(f"Processing frame {i}")
        # 混合帧和覆盖图
        blended_frame = blend_with_alpha(frame, overlay, i, total_frames)
        frames.append(blended_frame)

    # 保存修改后的帧为新的GIF文件
    # duration: duration of each frame in ms
    frames[0].save(output_gif_path,
                   format='GIF',
                   append_images=frames[1:],
                   save_all=True,
                   optimize=False,
                   loop=0,
                   # Disposal method 2 ensures previous frame is cleared before displaying the next one
                   disposal=2,
                   duration=duration_ms)
    # save_transparent_gif(frames, duration_ms, output_gif_path)

    '''
    fps = 1000 / duration_ms
    frames = [np.array(f) for f in frames]
    clip = mpy.ImageSequenceClip(frames, fps=fps)
    clip.write_gif(output_gif_path, fps=fps)
    '''


def main():
    input_gif = sys.argv[1]
    overlay_png = sys.argv[2]
    duration_ms = int(sys.argv[3])
    output_gif = "output.gif"
    process_gif(input_gif, overlay_png, output_gif, duration_ms)


if __name__ == '__main__':
    main()
