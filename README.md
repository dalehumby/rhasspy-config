# Rhasspy configuration

[Rhasspy](https://rhasspy.readthedocs.io/en/latest/) is an open source, fully offline, self hosted set of services that can be used to build a local-only voice assistant.

These are my config files, mostly as a backup and history of my changes, but maybe useful to others.


## Setup

I use Rhasspy in [satellite/base mode](https://rhasspy.readthedocs.io/en/latest/tutorials/#server-with-satellites). The satellites are each a Rasperry Pi 4B with Jabbra 410 USB conference speaker attached. The Pi satellites communicate with my main home server, a more powerful Dell that runs all my home automation Docker containers. (See [homelab](https://github.com/dalehumby/homelab), [homeassistant](https://github.com/dalehumby/homeassistant-config) and [esphome](https://github.com/dalehumby/esphome).)

Each Pi satellite constantly listens on the Jabbra mic for the wake word. I am using "Hey Mycroft" because it has the lowest latency, lowest false positive rate. When the wake word is detected Rhasspy on the Pi streams the audio over MQTT to the Rhasspy instance running on the main server. 

The server does Speech-to-text: I am using Mozilla DeepSpeech, although I did experiment with [Whisper](https://openai.com/blog/whisper/). (I may use Whisper in the future if the speed is better. Currently it takes around 8s to transcribe 3s of speech on my CPU, too slow for a realtime voice assistant.)

Rhasspy matches the text against the text in the sentences.ini and the files in intents using Fsticufs, built into Rhasspy.

Once an intent is matched the intent is handled by a Node-RED flow. This typically communicating with Home Assistant to turn on/off lights, run timers, get the weather, start the vacuum cleaner, etc.

Voice response (text-to-speech or TTS) is handled by [Mimic3](https://mycroft.ai/mimic-3/) and I use the ljspeech. This gives the most natural voice in the shortest amount of time.

## Why?
I wanted a way to create highly customised voice commands, and experiment with ideas I've had with how voice assistants should (could?) work. I also use Google Assistant at home, and Siri on my Watch and phone.
