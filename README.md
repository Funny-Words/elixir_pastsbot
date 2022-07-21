# Pastsbot

A simple selfbot written in elixir and created for trolling using [pastes](https://copypastatext.com/)

## Installation

```sh
git clone https://github.com/uebernihilist/elixir_pastsbot && cd elixir_pastsbot
mix compile
```

## Usage

After installation you need to create the following ENV variables:

``` text
TOKEN=your_token
ID=your_id
PREFIX=your_prefix
```

> PREFIX and ID are optional.
> The default prefix is $

To run, type

``` sh
MIX_ENV=prod iex -S mix
```

> If you want to receive debug logs, use MIX_ENV=dev instead

PROFIT!

### Commands

``` text
a [name] [paste] - add paste
g [name] - get paste by name
r [name] - remove paste
u [name] [paste] - update paste
s - force-save pastes
ga - get all the paste names
h - this help message
```

> Don't forget to insert the prefix before the command
