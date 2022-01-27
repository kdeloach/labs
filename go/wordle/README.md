# wordle solver

Basic utility to filter words to solve the wordle puzzle.

## Usage

```sh
$ go run wordle.go -h
Usage of /tmp/go-build142945034/b001/exe/wordle:
  -clues string
    	Comma separated list of clues. (ex. "arose:G-Y--,allot:G--Y-")
```

The format for `clues` is a comma separated list of `word:clue` pairs.

`word` is the word you guessed.

`clue` is the result of your guess.

`clue` format is `G-Y--` where `G` means "Right letter right spot", `Y` means
"Right letter wrong spot", and `-` means "Wrong letter".

## Demo

Imagine the correct answer is `pizza`.

I guess `arose`, `manly`, `whack` before finding the correct answer on the
fourth try.

```sh
$ go run wordle.go -clues "" | head -n 3
arose 0.06%
stare 0.06%
raise 0.06%

$ go run wordle.go -clues "arose:Y----" | head -n 3
manly 0.86%
candy 0.84%
canny 0.83%

$ go run wordle.go -clues "arose:Y----,manly:-Y---" | head -n 3
whack 18.26%
khaki 16.52%
quack 16.52%

$ go run wordle.go -clues "arose:Y----,manly:-Y---,whack:--Y--" | head -n 3
pizza 55.56%
tibia 44.44%
```

Imagine the correct answer is `audio`.

I guess `arose` and then `allot` before the word list is filtered down to one
possible result on the third try.

```sh
$ go run wordle.go -clues "arose:G-Y--" | head -n 3
allot 12.76%
allow 12.76%
alloy 12.76%

$ go run wordle.go -clues "arose:G-Y--,allot:G--Y-" | head -n 3
audio
```
