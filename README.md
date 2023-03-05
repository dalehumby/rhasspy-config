# Rhasspy configuration

[Rhasspy](https://rhasspy.readthedocs.io/en/latest/) is an open source, fully offline, self hosted set of services that can be used to build a local-only voice assistant.

These are my config files, mostly as a backup and history of my changes, but maybe useful to others.


## Setup

I use Rhasspy in [satellite/base mode](https://rhasspy.readthedocs.io/en/latest/tutorials/#server-with-satellites). The satellites are each a Rasperry Pi 4B with Jabbra 410 USB conference speaker attached. The Pi satellites communicate with my main home server, a more powerful Dell that runs all my home automation Docker containers. (See my [homelab](https://github.com/dalehumby/homelab), [homeassistant](https://github.com/dalehumby/homeassistant-config) and [esphome](https://github.com/dalehumby/esphome).)

### Base

The base is run as part of my Docker Swarm [home stack](https://github.com/dalehumby/homelab/blob/master/home-stack.yaml), with this repos `en/` folder mounted on a shared drive so Rhasspy base can get to the config from wherever its running.

### Satellites

Each satellite should copy `.asoundrc` into its home directory, and then run `docker compose up -d -f satellite-compose.yaml` to launch the local version of Rhasspy. 

Set up the siteId (also on the base), MQTT, PyAudio, Mycroft Precise, Hermes MQTT and aplay.

Each satellite constantly listens on the Jabbra mic for the wake word. I am using "Hey Mycroft" because, for me, it has the lowest latency, lowest false positive rate. When the wake word is detected Rhasspy satellite streams the audio over MQTT to the base instance running on the main server.

The server does speech-to-text: I am using Mozilla DeepSpeech, and experimenting with [Whisper](https://openai.com/blog/whisper/) by sending the raw wav to OpenAI Whisper API using [whisper.sh](en/whisper.sh).

Rhasspy matches the speech-to-text against the sentences.ini and intents/ files using Fsticufs, built into Rhasspy.

Once an intent is matched the intent is handled by a Node-RED flow. This typically communicating with Home Assistant to turn on/off lights, run timers, get the weather, start the vacuum cleaner, etc.

Voice response (text-to-speech or TTS) is handled by [Mimic3](https://mycroft.ai/mimic-3/). I use the ljspeech, which gives the most natural voice with the lowest latency.


## Why?

I wanted a way to create highly customised voice commands, and experiment with ideas I've had with how voice assistants should (could?) work. I also use Google Assistant at home, and Siri on my Watch and phone.
