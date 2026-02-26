#!/usr/bin/env python3
import argparse
import subprocess
import os
from typing import Optional


def get_video_duration(input_path: str) -> float:
    result = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", input_path],
        capture_output=True,
        text=True,
        check=True
    )
    return float(result.stdout.strip())


def calculate_bitrate(target_size_mb: float, duration: float, audio_bitrate_kbps: int = 192) -> int:
    target_size_bits = target_size_mb * 8 * 1024 * 1024
    audio_bits = audio_bitrate_kbps * 1000 * duration
    video_bits = target_size_bits - audio_bits
    video_bitrate_bps = max(video_bits / duration, 0)
    return int(video_bitrate_bps / 1000)


def convert_video(input_path: str, output_path: str, target_size_mb: Optional[float] = None, crf: int = 23, preset: str = "medium"):
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input file not found: {input_path}")

    output_dir = os.path.dirname(output_path)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)

    cmd = ["ffmpeg", "-i", input_path, "-y"]

    if target_size_mb:
        duration = get_video_duration(input_path)
        video_bitrate = calculate_bitrate(target_size_mb, duration)
        cmd.extend(["-b:v", f"{video_bitrate}k", "-bufsize", f"{video_bitrate * 2}k", "-maxrate", f"{video_bitrate * 1.5}k"])
        print(f"Targeting {target_size_mb}MB with calculated video bitrate: {video_bitrate}kbps")
    else:
        cmd.extend(["-crf", str(crf)])

    cmd.extend(["-preset", preset, "-c:v", "libx264", "-c:a", "aac", "-b:a", "192k", output_path])

    print(f"Running: {' '.join(cmd)}")
    subprocess.run(cmd, check=True)

    if target_size_mb:
        actual_size = os.path.getsize(output_path) / (1024 * 1024)
        print(f"Output file size: {actual_size:.2f}MB")


def main():
    parser = argparse.ArgumentParser(description="Convert video files to MP4 with optional compression")
    parser.add_argument("input", help="Input video file path")
    parser.add_argument("output", help="Output MP4 file path")
    parser.add_argument("--target-size", type=float, help="Target output file size in MB")
    parser.add_argument("--crf", type=int, default=23, help="Constant Rate Factor (0-51, lower = better quality, default: 23)")
    parser.add_argument("--preset", default="medium", choices=["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow"], help="Encoding preset (default: medium)")

    args = parser.parse_args()

    convert_video(args.input, args.output, args.target_size, args.crf, args.preset)


if __name__ == "__main__":
    main()
