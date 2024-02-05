# clag - Command Line AI Gem

Tired of trying to remember the exact flags to use or digging through
documentation or googling to find how to do the thing you're trying to do?

Suffer no more! Simply describe what you're trying to do and generate the
command with the help of an LLM!

## Installation

* Get an API key from OpenAI for gpt4-turbo: https://platform.openai.com/

* Set your API key as OPENAI\_API\_KEY in your environment

* Install the gem
`gem install clag`

* Generate commands
`clag g "create a new ruby on rails project using postgres and tailwindcss"`

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
