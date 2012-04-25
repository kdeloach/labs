Small script I wrote to experiment with parsing basic Python expressions and converting them 
to LISP syntax. Also, there is an option to simplify expressions as much as possible by evaluation.

    $ python main.py
    Usage: main.py [options] filename

    Options:
      -h, --help  show this help message and exit
      -r          simplify expressions as much as possible
      -t          run tests
      -a          use AST for parsing expression
      
Run the sample expressions from a text file:

    $ python main.py sample.txt
    3 * (8 / (2 * 2)) + x
    (+ (* 3 (/ 8 (* 2 2))) x)

    4 - 8 / 2 + 8 * 2
    (+ (- 4 (/ 8 2)) (* 8 2))
    
With `-r` flag:
    
    $ python main.py -r sample.txt
    3 * (8 / (2 * 2)) + x
    (+ 6 x)

    4 - 8 / 2 + 8 * 2
    16
    
