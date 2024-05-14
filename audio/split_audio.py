import sys
from os import listdir, walk, path
from pydub import AudioSegment
from pydub.utils import make_chunks
import datetime


def get_audio_duration(audio_file):
    audio = AudioSegment.from_file(audio_file, format='mp3')
    return len(audio) // 1000


def process_directory(root_dir, target_filename, chunk_length_seconds=120):
    for dirpath, dirnames, files in walk(root_dir):
        for filename in files:
            if filename == target_filename:
                print(f'Target file: {filename}')
                audio_path = path.join(dirpath, filename)
                duration = get_audio_duration(audio_path)
                if duration > chunk_length_seconds:
                    print(f'Processing {audio_path} (Duration: {datetime.timedelta(seconds=duration)})')
                    audio = AudioSegment.from_file(audio_path, format='mp3')
                    chunks = make_chunks(audio, chunk_length_seconds * 1000)
                    for i, chunk in enumerate(chunks):
                        chunk_filename = f'{path.splitext(filename)[0]}_chunk_{i+1}.mp3'
                        chunk_path = path.join(dirpath, chunk_filename)
                        chunk.export(chunk_path, format='mp3')
                        print(f'Splitted {audio_path} into {len(chunks)} chunks.')


def main():
    root_dir = sys.argv[1]
    target_filename = 'voice_txt.mp3'
    max_chunk_len = 110
    process_directory(root_dir, target_filename, max_chunk_len)


if __name__ == '__main__':
    main()
