# wordle solver

First attempt at a Wordle solver.

## Usage

```sh
$ go run wordle.go -h
Usage of /tmp/go-build4148900367/b001/exe/wordle:
  -allMatch string
    	Right letters right spot. (ex. "pi--a")
  -anyMatch string
    	Right letters wrong spot. Comma delimited list. (ex. "-a---,co---")
  -best
    	Find best word from filtered set.
  -noMatch string
    	Wrong letters. (ex. "xyz")
```

## Demo

Imagine the correct answer is `pizza`.

First, I run the command with blank arguments to see the top 3 best words to
start with.

```sh
$ go run wordle.go -allMatch "" -anyMatch "" -noMatch "" -best | head -n 3
arose 0.06%
stare 0.06%
raise 0.06%
```

I input `arose` as my first guess.

The letters `rose` don't match anything so I add those to `noMatch`. This
filters out all words containing those letters.

The letter `a` matches but it's in the wrong spot so I add `a----` to
`anyMatch`. This filters out all words that _don't_ contain `a`. Also, it
filters out words with `a` in that position.

```sh
$ go run wordle.go -allMatch "" -anyMatch "a----" -noMatch "rose" -best | head -n 3
manly 0.86%
candy 0.84%
canny 0.83%
```

Now the best word to guess is `manly`. I input this word as my next guess.

The letters `mnly` don't match anything so I append them to `noMatch` to filter
out words containing those letters.

The letter `a` matches, but it's in the wrong spot again, so I append `-a---`
to `anyMatch` to filter out all words with `a` in that position.

```sh
$ go run wordle.go -allMatch "" -anyMatch "a----,-a---" -noMatch "rosemnly" -best | head -n 3
whack 18.26%
khaki 16.52%
quack 16.52%
```

I input `whack` as my next guess.

The letters `whck` don't match anything so I append them to `noMatch`.

The letter `a` matches, but it's in the wrong spot again, so I append `--a--`
to `anyMatch`.

Finally, we see that the correct answer is the top result.

```sh
$ go run wordle.go -allMatch "" -anyMatch "a----,-a---,--a--" -noMatch "rosemnlywhck" -best | head -n 3
pizza 55.56%
tibia 44.44%
```

---

Here's another demo where the correct answer is `pizza`.

I guess `strip` and then `pinky` before it returns the only possible solution.

```sh
$ go run wordle.go -allMatch "" -anyMatch "---ip" -noMatch "stre" -best | head -n 3
pinky 10.20%
picky 9.60%
hippy 9.60%

$ go run wordle.go -allMatch "pi---" -anyMatch "---ip" -noMatch "strenky" -best | head -n 3
pizza
```
