import os
import sys
import argparse

import cv2
import numpy as np


class ImageStrokeProcessor:
    def __init__(self, stroke_width=5, feather_width=15, white_threshold=240):
        self.stroke_width = stroke_width
        self.feather_width = feather_width
        self.white_threshold = white_threshold

    def process(self, image_path):
        img = cv2.imread(image_path, cv2.IMREAD_COLOR)
        if img is None:
            raise ValueError(f"Cannot read image: {image_path}")
        rgba = self._white_to_alpha(img)
        return self._add_feathered_stroke(rgba)

    def _white_to_alpha(self, img):
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        rgba = np.zeros((img.shape[0], img.shape[1], 4), dtype=np.uint8)
        rgba[:, :, :3] = img[:, :, :3]

        alpha = np.full_like(gray, 255, dtype=np.uint8)
        alpha[gray >= self.white_threshold] = 0

        transition_band = 32
        transition_mask = (gray > (self.white_threshold - transition_band)) & (gray < self.white_threshold)
        if np.any(transition_mask):
            t = (self.white_threshold - gray[transition_mask].astype(np.float32)) / transition_band
            alpha[transition_mask] = (255 * t).astype(np.uint8)

        rgba[:, :, 3] = alpha
        return rgba

    def _add_feathered_stroke(self, rgba):
        alpha = rgba[:, :, 3]
        _, binary = cv2.threshold(alpha, 30, 255, cv2.THRESH_BINARY)

        total_width = self.stroke_width + self.feather_width
        if total_width <= 0:
            return rgba

        dist = cv2.distanceTransform(255 - binary, cv2.DIST_L2, cv2.DIST_MASK_PRECISE)

        stroke_alpha = np.zeros_like(dist, dtype=np.float32)

        inner_mask = (dist > 0) & (dist <= self.stroke_width)
        stroke_alpha[inner_mask] = 1.0

        feather_mask = (dist > self.stroke_width) & (dist <= total_width)
        if np.any(feather_mask):
            stroke_alpha[feather_mask] = 1.0 - (dist[feather_mask] - self.stroke_width) / self.feather_width

        if self.feather_width > 1:
            blur_sigma = self.feather_width / 2.0
            blur_ksize = max(3, int(blur_sigma * 4 + 1))
            if blur_ksize % 2 == 0:
                blur_ksize += 1

            feather_only = np.where(feather_mask, stroke_alpha, 0).astype(np.float32)
            feather_only[inner_mask] = 1.0
            feather_blurred = cv2.GaussianBlur(feather_only, (blur_ksize, blur_ksize), blur_sigma)
            feather_blurred = np.clip(feather_blurred, 0, 1)

            stroke_alpha = np.where(inner_mask, 1.0, np.where(feather_mask, feather_blurred, 0))

        result = rgba.copy().astype(np.float32)
        sa3 = np.dstack([stroke_alpha] * 3)

        result[:, :, :3] = 255.0 * sa3 + result[:, :, :3] * (1.0 - sa3)
        result[:, :, 3] = np.maximum(result[:, :, 3], stroke_alpha * 255.0)

        return result.astype(np.uint8)


def main():
    parser = argparse.ArgumentParser(
        description="Add feathered white stroke around subject after removing white background"
    )
    parser.add_argument("image", help="Path to input image")
    parser.add_argument("--stroke-width", type=int, default=5,
                        help="Width of the solid white stroke in pixels (default: 5)")
    parser.add_argument("--feather-width", type=int, default=15,
                        help="Width of the feathered transition in pixels (default: 15)")
    parser.add_argument("--threshold", type=int, default=240,
                        help="Luminance threshold for white background removal (default: 240)")
    parser.add_argument("-o", "--output", help="Output path (default: input_name_stroke.png)")

    args = parser.parse_args()

    if args.output:
        output_path = args.output
    else:
        basename = os.path.splitext(os.path.basename(args.image))[0]
        output_path = os.path.join(os.path.dirname(args.image) or ".",
                                   f"{basename}_stroke.png")

    processor = ImageStrokeProcessor(
        stroke_width=args.stroke_width,
        feather_width=args.feather_width,
        white_threshold=args.threshold,
    )
    result = processor.process(args.image)
    cv2.imwrite(output_path, result)
    print(f"Output saved to {output_path}")


if __name__ == "__main__":
    main()
