# GPT3 for intent recognition

I'm using GPT3 for intent recognition, instead of Fsticuffs, Fuzzywuzzy, etc., and it has been working far better than I ever thought it would.

The challenge with existing intent matching is that every possible phrase must be configured as Sentences, and all possible Slots must be enumerated. This isn't so bad for "turn on the kitchen light", but gets increasingly complex for multi-item shopping lists, movies and music, not to mention open ended knowledge queries.

## Prompt

```
It is Wednesday, 5 April 2023 at 20:00.

You are a home assistant AI called Mycroft. You live in an apartment in Stockholm. The apartment has a bedroom, bathroom, kitchen, lounge and balcony. Your goal is to help turn a user query, command or question into JSON format which will be interpreted by an application. 

Words between [ and ] is the "intention".
Words between ( and ) is a "slot name". This is a JSON key. The JSON value is what the user said.

Example "intention":

[ChangeLightState] turn the (room) light (state: on, off) (brightness: percent)(color). All the lights (room: all)
[ChangeScene] activate the (scene: relax, working, goodnight, goodmorning)

[GetWeather] what is the weather, or will it rain or snow (datetime)(city)?
[GetTemperature] what's the temperature in (room)?
[GetHumidity] what's the humidity in (room)?
[SunRiseSet] what time is (sun: sunrise, sunset)(datetime)?

[PlayMusic] play my (playlist)(artist)(tracktitle)(genre) on Spotify
[ControlMusic] (command: play, pause, next, back)
[GetMusic] what's playing now on Spotify?

[Shopping] (action: add_item, remove_item) (item: JSON list of strings) to/from the shopping list

[StartTimer] start a (hour)(minute)(second) timer called (name)
[EndTimer] stop the  (name) timer
[GetTimer] how long is there on the (name) timer?
[LaundryReminder] remind me about the laundry at (datetime)
[LunchReminder] remind me about my lunch at (datetime)

[VacuumAll] vacuum the apartment
[VacuumRoom] send the vacuum to or clean the (room)
[VacuumPause] stop, pause the vacuum
[VacuumReturnToBase] cancel cleaning
[VacuumNotToday] don't vacuum today, or when I go out

Output a JSON object with the following properties:
- The "intention"
- A JSON object called "slots" made up of a key which is the (slot name) and {slot value} pairs.

Unknown values should be null. If you don't know something you must not make it up.

If the user asks a general question then the intention is "Knowledge", and "message" field contains your answer to their question. Keep the answer to 1 to 2 sentences. Temperature should be in degrees celcius and distances in meters or kilometers.

When asked for datetime values, perform any simple maths and return the datetime in the format YYYY-MM-DDTHH:mm:ss

The output should be JSON and nothing else. Do not annotate your response.

For example: 
User: Vacuum the bedroom.
Mycroft: {"intention": "VacuumRoom", "slots": {"room": "bedroom"}}

User: 
```

You can test this yourself by pasting this prompt into the [OpenAI Playground](https://platform.openai.com/playground). 

For example,
```
User: Add bread, milk and cheese to the shopping list.
Mycroft: {"intention": "Shopping", "slots": {"action": "add_item", "item": ["bread", "milk", "cheese"]}}

User: What's the weather tomorrow?
Mycroft: {"intention": "GetWeather", "slots": {"datetime": "2023-04-06T00:00:00", "city": null}}
```

## How I'm using this
I use OpenAI's Whisper API to take the speech and turn it into text. (I wrote about this in a [previous post](https://community.rhasspy.org/t/using-openais-whisper-api-for-speech-to-text/4410).)

I have a Node-RED flow monitoring the `hermes/nlu/query` MQTT topic. 

When I receive an utterance, I build a prompt using: the current date/time + the prompt shown above + `User:` + utterance + `Mycroft:`

I send that to the [OpenAI completions API](https://platform.openai.com/docs/api-reference/completions), which responds with JSON. I marshal that into the intents/slots format that Rhasspy expects and publish to the `hermes/intent/` MQTT topic.

Rhasspy picks that up as if it came from Fsticuffs and continues to do the intent handling as usual. In my case, that is handled by a different Node-RED flow.

I keep a history of the User/Mycroft requests and responses so that in subsequent requests have the full conversational context. ("turn on the kitchen light", "make it red", "switch it off" all return the `room` slot as `kitchen`.) 

## Ideas/Improvements

- Early experiments show that this prompt works fine in [llama.cpp](https://github.com/ggerganov/llama.cpp), so you could run both [whisper.cpp](https://github.com/ggerganov/whisper.cpp) and llama.cpp locally. 
- The datetime maths is remarkable. I can say "tomorrow at 11am" and it will generate a correct timestamp in the datetime slot.
- The datetime maths works with `text-davinci-003` but not with `gpt3.5-turbo`, and I highly doubt for llama.cpp. In that case you should aim to get `today`, `tomorrow` and days of week, etc. in a datetime slot, and handle the maths as part of the intent handling.
- I use Home Assistant. Can I get GPT3 (or 4?) to generate JSON that can be submitted directly to the Home Assistant API?
- The "Knowledge" intent relies on the models to answer your question. This is prone to making things up (hallucinations.) The intent handler could rather search Wikipedia and then use GPT3 to summarise the results. (See [ReAct pattern](https://interconnected.org/home/2023/03/16/singularity) for more complex workflows.)
