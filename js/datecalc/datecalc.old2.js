enum TokenType {
    Number = "NUMBER",
    Unit = "UNIT",
    Slash = "SLASH",
    Plus = "PLUS",
    Minus = "MINUS",
    As = "AS",
}

class Token {
    constructor(
        public tokenType: TokenType,
        public value: string="") {
    }

    toString() {
        if (this.value) {
            return `Token(${this.tokenType} ${this.value})`;
        }
        return `Token(${this.tokenType})`;
    }
}

///

class DateCalcNode {
}

class DateNode extends DateCalcNode {
    constructor(
        public m: Token,
        public d: Token,
        public y: Token) {
            super();
    }
}

class DeltaNode extends DateCalcNode {
    constructor(
        public amount: Token,
        public unit: Token) {
            super();
    }
}

class PlusNode extends DateCalcNode {
    constructor(
        public left: DateCalcNode,
        public right: DateCalcNode) {
            super();
    }
}

class MinusNode extends DateCalcNode {
    constructor(
        public left: DateCalcNode,
        public right: DateCalcNode) {
            super();
    }
}

class CastNode extends DateCalcNode {
    constructor(
        public left: DateCalcNode,
        public unit: Token) {
            super();
    }
}

///

interface Indexable<T> {
    [index: number]: T
    length: number
}

class Iterator<T> {
    index: number = -1;

    constructor(private source: Indexable<T>) {
    }

    hasNext(): boolean {
       return this.index < this.source.length - 1;
    }

    next(): T {
        return this.source[++this.index];
    }

    current(): T {
        return this.source[this.index];
    }

    peek(): T {
        return this.source[this.index + 1];
    }
}

class TokenIterator extends Iterator<Token> {
    expect(tokenType: TokenType): Token {
        if (!this.hasNext()) {
            throw new ParseError(`expected "${tokenType}" but got nothing`);
        }
        let token = super.next();
        if (token.tokenType != tokenType) {
            throw new ParseError(`expected "${tokenType}" but got "${token.tokenType}"`);
        }
        return token;
    }
}

class ParseError {
    constructor(public readonly message: string) {
    }
}

function tokenize(program: string): Token[] {
    let tokens: Token[] = [];
    let stream = new Iterator(program);

    function scanWord(): string {
        let word = stream.current();
        while (stream.hasNext() && isAlpha(stream.peek())) {
            word += stream.next();
        }
        return word;
    }

    function scanNumber(): string {
        let num = stream.current();
        while (stream.hasNext() && isDigit(stream.peek())) {
            num += stream.next();
        }
        return num;
    }

    let units = [
        "second", "seconds",
        "minute", "minutes",
        "hour", "hours",
        "day", "days",
        "week", "weeks",
        "month", "months",
        "year", "years",
    ];

    while (stream.hasNext()) {
        let c = stream.next();
        if (c == " ") {
            continue;
        } else if (c == "/") {
            tokens.push(new Token(TokenType.Slash));
        } else if (c == "+") {
            tokens.push(new Token(TokenType.Plus));
        } else if (c == "-") {
            tokens.push(new Token(TokenType.Minus));
        } else if (isAlpha(c)) {
            let word = scanWord();
            if (word == "as") {
                tokens.push(new Token(TokenType.As));
            } else if (units.includes(word)) {
                tokens.push(new Token(TokenType.Unit, word));
            } else {
                throw new ParseError(`unexpected unit: ${word}`);    
            }
        } else if (isDigit(c)) {
            tokens.push(new Token(TokenType.Number, scanNumber()));
        } else {
            throw new ParseError(`unexpected character: ${c}`);
        }
    }

    return tokens;
}

const ALPHA_RE = /[a-z]/;
const DIGIT_RE = /[0-9]/;

function isAlpha(c: string): boolean {
    return ALPHA_RE.test(c);
}

function isDigit(c: string): boolean {
    return DIGIT_RE.test(c);
}

function parse(tokens: Token[]): DateCalcNode {
    let stream = new TokenIterator(tokens);

    function parseProgram(): DateCalcNode {
        let dateOrDelta = parseDateOrDelta();
        return parseDateExpr(dateOrDelta);
    }

    function parseDateOrDelta(): DateCalcNode {
        stream.expect(TokenType.Number);
        let nextToken = stream.peek();
        if (!nextToken) {
            throw new ParseError(`unexpected end of program`);
        }
        if (nextToken.tokenType == TokenType.Slash) {
            return parseDate();
        } else {
            return parseDelta();
        }
    }

    function parseDate(): DateCalcNode {
        let m = stream.current();
        stream.expect(TokenType.Slash);
        let d = stream.expect(TokenType.Number);
        stream.expect(TokenType.Slash);
        let y = stream.expect(TokenType.Number);
        return new DateNode(m, d, y);
    }

    function parseDelta(): DateCalcNode {
        let amount = stream.current();
        let unit = stream.expect(TokenType.Unit);
        return new DeltaNode(amount, unit);
    }
 
    function parseDateExpr(left: DateCalcNode): DateCalcNode {
        if (stream.hasNext()) {
            let nextToken = stream.next();
            let op = nextToken.tokenType == TokenType.Plus ? PlusNode :
                nextToken.tokenType == TokenType.Minus ? MinusNode : null;
            if (op) {
                let dateOrDelta = parseDateOrDelta();
                return new op(left, parseDateExpr(dateOrDelta));
            } else if (nextToken.tokenType == TokenType.As) {
                return new CastNode(left, nextToken);
            }
        }
        return left;
    } 

    let result = parseProgram();
    if (stream.hasNext()) {
        throw new ParseError(`unexpected tokens after program end: ${tokens.splice(stream.index + 1)}`);
    }
    return result;
}

try {
    let tokens = tokenize("1 hour as minutes");
    console.log(tokens);
    let nodes = parse(tokens);
    console.log(nodes);
} catch (ex) {
    console.error(ex);
}
