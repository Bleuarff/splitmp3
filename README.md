# SplitMP3

Little utility to split MP3 files into small chunks

## Usage

```bash
./splitmp3 DURATION SOURCE_FOLDER
```

_DURATION_: chunk length, in minutes  
_SOURCE_FOLDER_: folder where the script looks for files to slice.

Trailing track duration over chunk length is appended to the last chunk.  
Outputs mp3 files in the same directory. 

## Dependencies

- ffmpeg