#!/usr/bin/env bash

# First argument is OpenAi API key

# WAV data is avaiable via STDIN
wav_file=/profiles/en/speech.wav
cat > $wav_file

curl https://api.openai.com/v1/audio/transcriptions \
  -X POST \
  -H "Authorization: Bearer $1" \
  -H "Content-Type: multipart/form-data" \
  -F file=@$wav_file \
  -F model=whisper-1 \
  -F response_format=text \
  | sed -e "s/[[:punct:]]//g" | sed -e "s/\(.*\)/\L\1/"

# Remove puncutation and make lower case

# Transcription on stdout
