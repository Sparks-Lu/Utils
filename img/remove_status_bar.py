#!/usr/bin/env python3
"""
Remove top status bar from phone screen capture images.

This script detects and removes the status bar area from phone screenshots,
supporting various phone resolutions and offering multiple processing modes.
"""

import argparse
import os
import sys
from pathlib import Path
from typing import Optional, Tuple

try:
    from PIL import Image
except ImportError:
    print("Error: Pillow library is required. Install with: pip install Pillow")
    sys.exit(1)


# Common phone resolution status bar heights (in pixels)
STATUS_BAR_HEIGHTS = {
    # iPhone (notch models)
    (1170, 2532): 54,   # iPhone 12/13/14 Pro
    (1284, 2778): 54,   # iPhone 12/13/14 Pro Max
    (1179, 2556): 59,   # iPhone 14 Pro
    (1290, 2796): 60,   # iPhone 14 Pro Max
    (1185, 2556): 59,   # iPhone 15 Pro
    (1296, 2796): 60,   # iPhone 15 Pro Max
    # iPhone (older models)
    (750, 1334): 20,    # iPhone 6/7/8
    (828, 1792): 44,    # iPhone XR/11
    (1125, 2436): 44,   # iPhone X/XS
    (1242, 2688): 44,   # iPhone XS Max
    # Android common resolutions
    (1080, 1920): 24,   # Standard Android
    (1080, 2160): 24,   # 18:9 aspect
    (1080, 2220): 24,   # 18.5:9 aspect
    (1080, 2244): 24,   # 18.7:9 aspect
    (1080, 2280): 24,   # 19:9 aspect
    (1080, 2340): 25,   # 19.5:9 aspect
    (1080, 2400): 25,   # 20:9 aspect
    (1080, 2460): 25,   # 20.5:9 aspect
    (1080, 2520): 25,   # 21:9 aspect
    (1440, 2560): 24,   # QHD Android
    (1440, 2960): 25,   # QHD+ Samsung
    (1440, 3040): 25,   # QHD+ LG
    (1440, 3088): 27,   # QHD+ OnePlus
    (1440, 3200): 28,   # QHD+ newer
    # iPad
    (1668, 2388): 20,   # iPad Pro 10.5
    (2048, 2732): 20,   # iPad Pro 12.9
    # Default fallbacks based on aspect ratio
    "default_notch": 50,
    "default_standard": 25,
}

# Common phone screen widths for detecting scrolling screenshots
COMMON_PHONE_WIDTHS = [
    375,  # iPhone 6/7/8
    390,  # iPhone 12/13/14 Pro
    393,  # iPhone 14/15 Pro
    414,  # iPhone Plus/Max
    360,  # Common Android
    384,  # Common Android
    390,  # Common Android
    412,  # Pixel
    540,  # Half HD Android
    720,  # HD Android
    1080, # Full HD Android
    1440, # QHD Android
]


def detect_screen_dimensions(width: int, height: int) -> Tuple[int, int]:
    """
    Detect actual phone screen dimensions from a potentially scrolling screenshot.
    
    Args:
        width: Image width in pixels
        height: Image height in pixels
        
    Returns:
        Tuple of (screen_width, screen_height)
    """
    aspect_ratio = height / width if width > 0 else 2
    
    # If aspect ratio is very tall (> 3:1), likely a scrolling screenshot
    if aspect_ratio > 3.0:
        # Find the closest common phone width
        closest_width = min(COMMON_PHONE_WIDTHS, key=lambda w: abs(w - width))
        
        # Estimate screen height based on common aspect ratios (19.5:9 to 21:9)
        # Typical range: 2.1 to 2.3 aspect ratio
        estimated_height = int(closest_width * 2.2)  # Average ~2.2:1
        
        return (closest_width, estimated_height)
    
    # Normal screenshot - use actual dimensions
    return (width, height)


def detect_status_bar_height(width: int, height: int, is_scrolling: bool = False) -> int:
    """
    Detect the status bar height based on image resolution.
    
    Args:
        width: Image width in pixels
        height: Image height in pixels
        is_scrolling: Whether this is a scrolling screenshot
        
    Returns:
        Estimated status bar height in pixels
    """
    # For scrolling screenshots, use width to determine device type
    if is_scrolling:
        # Find closest phone width to determine device class
        closest_width = min(COMMON_PHONE_WIDTHS, key=lambda w: abs(w - width))
        
        # Default based on width - more reliable than matching exact resolutions
        if closest_width >= 1080:
            return 28  # Modern high-res Android (QHD+)
        elif closest_width >= 720:
            return 25  # HD Android / Modern phones
        elif closest_width >= 400:
            return 44  # iPhone with notch (375-414pt logical width)
        else:
            return 24  # Standard Android
    
    # Check exact resolution match
    if (width, height) in STATUS_BAR_HEIGHTS:
        return STATUS_BAR_HEIGHTS[(width, height)]
    
    # Check reversed (portrait/landscape)
    if (height, width) in STATUS_BAR_HEIGHTS:
        return STATUS_BAR_HEIGHTS[(height, width)]
    
    # Estimate based on aspect ratio and height
    aspect_ratio = height / width if width > 0 else 2
    
    if aspect_ratio > 2.0:
        # Very tall screen, likely has notch
        return STATUS_BAR_HEIGHTS["default_notch"]
    elif aspect_ratio > 1.7:
        # Standard modern phone
        return STATUS_BAR_HEIGHTS["default_standard"]
    else:
        # Tablet or older phone
        return 20


def detect_repeated_status_bars(
    image: Image.Image, 
    expected_height: int,
    min_screen_height: int = 400,
) -> list:
    """
    Detect repeated status bars in a scrolling screenshot.
    Uses edge detection to find horizontal lines that indicate screen boundaries.
    
    Args:
        image: PIL Image object
        expected_height: Expected status bar height
        min_screen_height: Minimum expected screen content height
        
    Returns:
        List of y-positions where status bars are detected
    """
    width, height = image.size
    
    # For most scrolling screenshots, just return the top position
    # Users should use manual mode if they need specific handling
    repeated_positions = [0]
    
    # Try to detect screen boundaries by looking for sharp horizontal transitions
    # This works best when screenshots are stitched with visible separators
    pixels = image.load()
    
    # Sample the center column for vertical analysis
    center_x = width // 2
    
    # Look for repeating patterns by analyzing brightness transitions
    screen_heights = []
    prev_significant_y = None
    
    for y in range(min_screen_height // 2, height - min_screen_height // 2, 10):
        # Check for a horizontal line pattern (status bar boundary)
        # Sample a small region
        region_brightness = []
        for dx in range(-width // 4, width // 4, max(1, width // 20)):
            x = center_x + dx
            if 0 <= x < width and 0 <= y < height:
                pixel = pixels[x, y]  # type: ignore
                if isinstance(pixel, tuple):
                    brightness = sum(pixel[:3]) / 3
                else:
                    brightness = int(pixel)  # type: ignore
                region_brightness.append(brightness)
        
        if region_brightness:
            avg_brightness = sum(region_brightness) / len(region_brightness)
            
            # Look for sudden brightness changes that might indicate boundaries
            if prev_significant_y is not None:
                spacing = y - prev_significant_y
                # If spacing is consistent with screen height, this might be a boundary
                if abs(spacing - min_screen_height) < min_screen_height * 0.3:
                    # Verify by checking if there's a visible line/separator
                    if is_horizontal_boundary(image, y, width):
                        screen_heights.append(spacing)
                        repeated_positions.append(y)
                        prev_significant_y = y
            else:
                prev_significant_y = y
    
    # If we found consistent screen heights, use them
    if len(screen_heights) >= 2:
        # Verify positions are at regular intervals
        avg_screen_height = sum(screen_heights) / len(screen_heights)
        filtered = [0]
        for pos in repeated_positions[1:]:
            if all(abs(pos - p) > avg_screen_height * 0.7 for p in filtered):
                filtered.append(pos)
        return filtered
    
    # Default: just the top status bar
    return repeated_positions


def is_horizontal_boundary(image: Image.Image, y: int, width: int, threshold: int = 3) -> bool:
    """
    Check if there's a visible horizontal line/boundary at position y.
    
    Args:
        image: PIL Image object
        y: Y position to check
        width: Image width
        threshold: Minimum contrast threshold
        
    Returns:
        True if a boundary is detected
    """
    pixels = image.load()
    height = image.size[1]
    
    # Sample points along the horizontal line
    boundary_pixels = []
    above_pixels = []
    below_pixels = []
    
    for x in range(0, width, max(1, width // 50)):
        if 0 <= x < width:
            if 0 <= y < height:
                boundary_pixels.append(pixels[x, y])  # type: ignore
            if 0 <= y - 1 < height:
                above_pixels.append(pixels[x, y - 1])  # type: ignore
            if 0 <= y + 1 < height:
                below_pixels.append(pixels[x, y + 1])  # type: ignore
    
    # Check if boundary line is distinctly different from surroundings
    if not boundary_pixels or not above_pixels or not below_pixels:
        return False
    
    def avg_brightness(pixels_list):
        total = 0
        for p in pixels_list:
            if isinstance(p, tuple):
                total += sum(p[:3]) / 3
            else:
                total += int(p)  # type: ignore
        return total / len(pixels_list)
    
    boundary_brightness = avg_brightness(boundary_pixels)
    above_brightness = avg_brightness(above_pixels)
    below_brightness = avg_brightness(below_pixels)
    
    # Check for contrast
    contrast_above = abs(boundary_brightness - above_brightness)
    contrast_below = abs(boundary_brightness - below_brightness)
    
    return contrast_above > threshold or contrast_below > threshold


def detect_status_bar_by_content(image: Image.Image, max_height: int = 150) -> int:
    """
    Attempt to detect status bar by analyzing image content.
    Looks for the boundary where the screenshot content begins.
    
    Args:
        image: PIL Image object
        max_height: Maximum height to search for status bar
        
    Returns:
        Detected status bar height in pixels
    """
    width, height = image.size
    pixels = image.load()
    
    # Sample columns from left, center, and right
    sample_x = [width // 4, width // 2, 3 * width // 4]
    
    # Look for the first row that has significant content change
    # Status bars are often solid color or gradient
    prev_colors = []
    
    for y in range(min(max_height, height)):
        row_colors = []
        for x in sample_x:
            if 0 <= x < width and 0 <= y < height:
                pixel = pixels[x, y]  # type: ignore
                if pixel is not None:
                    row_colors.append(pixel)
        
        if prev_colors and row_colors:
            # Check if colors are significantly different from previous row
            # This might indicate the start of actual content
            color_diff = 0
            for curr, prev in zip(row_colors, prev_colors):
                if isinstance(curr, tuple) and isinstance(prev, tuple):
                    # Handle RGB/RGBA tuples - extract first 3 values for RGB comparison
                    curr_rgb = curr[:3] if len(curr) >= 3 else tuple(int(c) for c in curr) * 3
                    prev_rgb = prev[:3] if len(prev) >= 3 else tuple(int(c) for c in prev) * 3
                    diff = sum(abs(c - p) for c, p in zip(curr_rgb, prev_rgb))
                    color_diff += diff
                elif isinstance(curr, (int, float)) and isinstance(prev, (int, float)):
                    # Handle grayscale values
                    diff = abs(int(curr) - int(prev)) * 3
                    color_diff += diff
            
            # If there's a significant color change, this might be the boundary
            if color_diff > 300:  # Threshold for color change
                return max(y - 5, 0)  # Return a bit before the change
        
        prev_colors = row_colors
    
    # Fall back to resolution-based detection
    return detect_status_bar_height(width, height)


def remove_status_bar(
    image_path: str,
    output_path: Optional[str] = None,
    status_bar_height: Optional[int] = None,
    mode: str = "crop",
    auto_detect: bool = True,
    fill_color: Optional[Tuple[int, int, int]] = None,
    remove_all: bool = False,
) -> str:
    """
    Remove the status bar from a phone screenshot.
    
    Args:
        image_path: Path to input image
        output_path: Path for output image (default: input_path with _no_statusbar suffix)
        status_bar_height: Manual status bar height (default: auto-detect)
        mode: Processing mode - 'crop', 'blur', or 'fill'
        auto_detect: Use content analysis for detection
        fill_color: Color to fill when mode='fill' (default: match top edge)
        remove_all: Remove all repeated status bars (for scrolling screenshots)
        
    Returns:
        Path to the output image
    """
    # Load image
    try:
        img = Image.open(image_path)
    except Exception as e:
        raise ValueError(f"Failed to open image: {e}")
    
    # Convert to RGB if necessary (handle PNG with transparency, etc.)
    if img.mode in ('RGBA', 'P'):
        img = img.convert('RGB')
    elif img.mode != 'RGB':
        img = img.convert('RGB')
    
    img_width, img_height = img.size
    
    # Detect if this is a scrolling screenshot (very tall aspect ratio)
    aspect_ratio = img_height / img_width if img_width > 0 else 2
    is_scrolling = aspect_ratio > 3.0
    
    if is_scrolling:
        print(f"  Scrolling screenshot detected")
    
    # Determine status bar height
    if status_bar_height is not None:
        # User specified height - use it directly
        pass  # status_bar_height already set
    elif is_scrolling:
        # For scrolling screenshots, use width to determine device type
        # Content detection is unreliable on very tall images
        status_bar_height = detect_status_bar_height(img_width, img_height, is_scrolling)
    else:
        # Regular screenshot - use content detection
        if auto_detect:
            status_bar_height = detect_status_bar_by_content(img)
        else:
            status_bar_height = detect_status_bar_height(img_width, img_height, is_scrolling)
    
    # Validate height - ensure reasonable bounds
    if status_bar_height is None or status_bar_height <= 0:
        status_bar_height = 25  # Safe default
    elif status_bar_height > 150:
        # For very large values, assume it's a detection error
        status_bar_height = detect_status_bar_height(img_width, img_height, is_scrolling)
    
    print(f"  Image size: {img_width}x{img_height}")
    print(f"  Status bar height: {status_bar_height}px")
    
    # Generate output path if not provided
    if output_path is None:
        input_path = Path(image_path)
        output_path = str(input_path.parent / f"{input_path.stem}_no_statusbar{input_path.suffix}")
    
    # Process based on mode - always just handle the single top status bar
    if mode == "crop":
        # Simply crop out the status bar
        result = img.crop((0, status_bar_height, img_width, img_height))
        
    elif mode == "blur":
        # Blur the status bar area
        result = img.copy()
        status_bar = img.crop((0, 0, img_width, status_bar_height))
        # Apply box blur
        from PIL import ImageFilter
        blurred = status_bar.filter(ImageFilter.BoxBlur(radius=status_bar_height // 2))
        result.paste(blurred, (0, 0))
        
    elif mode == "fill":
        # Fill status bar with solid color
        result = img.copy()
        if fill_color is None:
            # Sample color from just below status bar
            sample_y = min(status_bar_height + 5, img_height - 1)
            sampled_color = img.getpixel((img_width // 2, sample_y))  # type: ignore
            # Ensure we have an RGB tuple (image was converted to RGB earlier)
            if isinstance(sampled_color, tuple):
                fill_color = tuple(int(c) for c in sampled_color[:3])  # type: ignore
            else:
                # Grayscale - convert to RGB
                gray_val = int(sampled_color)  # type: ignore
                fill_color = (gray_val, gray_val, gray_val)
        
        from PIL import ImageDraw
        draw = ImageDraw.Draw(result)
        draw.rectangle([0, 0, img_width, status_bar_height], fill=fill_color)
        
    else:
        raise ValueError(f"Unknown mode: {mode}. Use 'crop', 'blur', or 'fill'")
    
    # Save result
    # Preserve quality for JPEG
    save_kwargs = {}
    if output_path.lower().endswith('.jpg') or output_path.lower().endswith('.jpeg'):
        save_kwargs['quality'] = 95
        save_kwargs['optimize'] = True
    elif output_path.lower().endswith('.png'):
        save_kwargs['optimize'] = True
    
    result.save(output_path, **save_kwargs)
    print(f"  Saved to: {output_path}")
    
    return output_path


def process_directory(
    input_dir: str,
    output_dir: Optional[str] = None,
    height: Optional[int] = None,
    mode: str = "crop",
    auto_detect: bool = True,
    recursive: bool = False,
    remove_all: bool = False,
) -> Tuple[int, int]:
    """
    Process all images in a directory.
    
    Args:
        input_dir: Input directory path
        output_dir: Output directory (default: same as input)
        height: Manual status bar height
        mode: Processing mode
        auto_detect: Use content analysis
        recursive: Search subdirectories
        remove_all: Remove all repeated status bars
        
    Returns:
        Tuple of (successful_count, failed_count)
    """
    input_path = Path(input_dir)
    
    if output_dir:
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
    else:
        output_path = input_path
    
    # Find all image files
    image_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.webp', '.tiff', '.tif'}
    
    if recursive:
        image_files = [
            f for f in input_path.rglob('*')
            if f.suffix.lower() in image_extensions
        ]
    else:
        image_files = [
            f for f in input_path.iterdir()
            if f.is_file() and f.suffix.lower() in image_extensions
        ]
    
    if not image_files:
        print(f"No image files found in {input_dir}")
        return 0, 0
    
    print(f"Found {len(image_files)} image(s) to process\n")
    
    success_count = 0
    fail_count = 0
    
    for image_file in sorted(image_files):
        try:
            # Determine output path
            if output_dir:
                rel_path = image_file.relative_to(input_path)
                out_file = output_path / rel_path
                out_file.parent.mkdir(parents=True, exist_ok=True)
            else:
                out_file = None  # Use default naming
            
            print(f"Processing: {image_file.name}")
            remove_status_bar(
                str(image_file),
                output_path=str(out_file) if out_file else None,
                status_bar_height=height,
                mode=mode,
                auto_detect=auto_detect,
                remove_all=remove_all,
            )
            success_count += 1
            print()
            
        except Exception as e:
            print(f"  Error: {e}\n")
            fail_count += 1
    
    return success_count, fail_count


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Remove top status bar from phone screen capture images.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s screenshot.png                    # Process single file
  %(prog)s screenshot.png -o output.png      # Specify output file
  %(prog)s screenshot.png -H 50              # Manual status bar height
  %(prog)s screenshots/                      # Process directory
  %(prog)s screenshots/ -r                   # Recursive directory
  %(prog)s screenshot.png -m blur            # Blur instead of crop
  %(prog)s screenshot.png -m fill            # Fill with solid color
  %(prog)s scrolling.png -H 44               # Scrolling screenshot with manual height

Note: Scrolling screenshots are auto-detected. Only the top status bar is removed.
        """
    )
    
    parser.add_argument(
        "input",
        help="Input image file or directory"
    )
    
    parser.add_argument(
        "-o", "--output",
        help="Output file or directory path"
    )
    
    parser.add_argument(
        "-H", "--height",
        type=int,
        dest="status_height",
        help="Manual status bar height: 20 (old iPhone), 24-28 (Android), 44 (iPhone notch), 50-60 (iPhone Pro)"
    )
    
    parser.add_argument(
        "-m", "--mode",
        choices=["crop", "blur", "fill"],
        default="crop",
        help="Processing mode: crop (remove), blur, or fill (default: crop)"
    )
    
    parser.add_argument(
        "--no-auto",
        action="store_true",
        help="Disable content-based auto detection"
    )
    
    parser.add_argument(
        "-r", "--recursive",
        action="store_true",
        help="Recursively process subdirectories"
    )
    
    parser.add_argument(
        "-a", "--remove-all",
        action="store_true",
        help=argparse.SUPPRESS  # Hidden - for special cases with repeated status bars
    )
    
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output"
    )
    
    args = parser.parse_args()
    
    input_path = Path(args.input)
    
    if not input_path.exists():
        print(f"Error: Input path does not exist: {args.input}")
        sys.exit(1)
    
    print(f"{'='*50}")
    print(f"Status Bar Remover")
    print(f"{'='*50}\n")
    
    if input_path.is_file():
        # Process single file
        try:
            remove_status_bar(
                str(input_path),
                output_path=args.output,
                status_bar_height=args.status_height,
                mode=args.mode,
                auto_detect=not args.no_auto,
                remove_all=args.remove_all,
            )
            print(f"\nDone!")
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)
            
    elif input_path.is_dir():
        # Process directory
        success, failed = process_directory(
            str(input_path),
            output_dir=args.output,
            height=args.status_height,
            mode=args.mode,
            auto_detect=not args.no_auto,
            recursive=args.recursive,
            remove_all=args.remove_all,
        )
        
        print(f"\n{'='*50}")
        print(f"Processing complete!")
        print(f"  Successful: {success}")
        print(f"  Failed: {failed}")
        print(f"{'='*50}")
        
        if failed > 0:
            sys.exit(1)
    else:
        print(f"Error: Invalid input path: {args.input}")
        sys.exit(1)


if __name__ == "__main__":
    main()
