# clag - Command Line AI Gem

Tired of trying to remember the exact flags to use or digging through
documentation or googling to find how to do the thing you're trying to do?

Suffer no more! Simply describe what you're trying to do and generate the
command with the help of an LLM!

## Installation

* Install the gem
`gem install clag`

* Generate commands
`clag g "create a new ruby on rails project using postgres and tailwindcss"`

### Using OpenAI's GPT-4

* Get an API key from OpenAI for gpt4-turbo: https://platform.openai.com/

* Set your API key as OPENAI\_API\_KEY in your environment


### Using Google's Gemini 1.0

* Get an API key from Google's AI Studio at https://ai.google.dev/

* Set your API key as GEMINI\_API\_KEY in your environment

* Select Gemini as your preferred LLM by setting CLAG\_LLM=gemini in your
  environment

### Using Anthropic's Claude 3 Opus

* Get an API key from Anthropic at https://www.anthropic.com/

* Set your API key as ANTHROPIC\_API\_KEY in your environment

* Select Claude 3 Opus as your preferred LLM by setting CLAG\_LLM=claude in
  your environment

### Using Groq on Mixtral

* Get an API key from https://console.groq.com/

* Set your API key as GROQ\_API\_KEY in your environment

* Select Groq as your preferred LLM by setting CLAG\_LLM=groq in your environment

### Using a Local Model

* Have a model locally from either Ollama or Llamafile with an OpenAI compatible
  API

* Have the API server running on port 8080

* Select local as your preferred LLM by setting CLAG\_LLM=local in your environment

## Usage

Currently support one command: "g".

`clag g "the command you'd like to generate"`

## Contributing

Bug reports and pull requests are welcome on Github at
https://github.com/sublayerapp/clag

## Community

Like what you see, or looking for more people working on the future of
programming with LLMs? Come join us in the [Promptable Architecture
Discord](https://discord.gg/sjTJszPwXt)
