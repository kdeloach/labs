Small script I wrote to experiment with AST to convert basic Python expressions
to LISP syntax. Also, there is an option to simplify expressions as much as possible by evaluation.

    $ python lispify.py sample.txt
    3 * (8 / (2 * 2)) + x
    (+ (* 3 (/ 8 (* 2 2))) x)

    4 - 8 / 2 + 8 * 2
    (+ (- 4 (/ 8 2)) (* 8 2))
    
With `-r` flag:
    
    $ python lispify.py sample.txt -r
    3 * (8 / (2 * 2)) + x
    (+ 6 x)

    4 - 8 / 2 + 8 * 2
    16