enum TokenType {
    Word = "WORD",
    Number = "NUMBER",
    Slash = "SLASH",
    Plus = "PLUS",
    Minus = "MINUS",
    Date = "DATE",
    Delta = "DELTA",
    Cast = "CAST",
}

class Token {
    constructor(public tokenType: TokenType) {
    }

    toString() {
        return `Token(${this.tokenType})`;
    }
}

class LiteralToken extends Token {
    constructor(
        public tokenType: TokenType,
        public value: string) {
            super(tokenType);
    }
}

class DateToken extends Token {
    constructor(
        public m: Token,
        public d: Token,
        public y: Token) {
            super(TokenType.Date);
    }
}

class DeltaToken extends Token {
    constructor(
        public amount: Token,
        public unit: Token) {
            super(TokenType.Delta);
    }
}

class CastToken extends Token {
    constructor(public unit: Token) {
        super(TokenType.Cast);
    }
}

///

type DateCalcNode = DateToken | DeltaToken | BinaryOpNode;

class BinaryOpNode {
    constructor(
        public token: Token,
        public left: DateCalcNode,
        public right: DateCalcNode) {
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
        let token = super.next();
        if (!token) {
            throw new ParseError(`expected "${tokenType}" but got nothing`);
        }
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
            tokens.push(new LiteralToken(TokenType.Word, scanWord()));
        } else if (isDigit(c)) {
            tokens.push(new LiteralToken(TokenType.Number, scanNumber()));
        } else {
            throw new ParseError(`unexpected character: ${c}`);
        }
    }

    // Reduce tokens:
    // <number> / <number> / <number> -> <date>
    // <number> <word> -> <delta>
    let newTokens: Token[] = [];
    let tokenStream = new TokenIterator(tokens);
    while (tokenStream.hasNext()) {
        let token = tokenStream.next();
        if (token.tokenType == TokenType.Number) {
            let nextToken = tokenStream.peek();
            if (nextToken.tokenType == TokenType.Word) {
                tokenStream.expect(TokenType.Word);
                newTokens.push(new DeltaToken(token, nextToken));
            } else if (nextToken.tokenType == TokenType.Slash) {
                tokenStream.expect(TokenType.Slash);
                let d = tokenStream.expect(TokenType.Number);
                tokenStream.expect(TokenType.Slash);
                let y = tokenStream.expect(TokenType.Number);
                newTokens.push(new DateToken(token, d, y));
            } else {
                throw new ParseError(`unexpected token: ${token}`);
            }
        } else {
            newTokens.push(token);
        }
    }
    tokens = newTokens;

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
        let token = stream.peek();
        if (token.tokenType == TokenType.Date) {
            return parseDateExpr();
        } else if (token.tokenType == TokenType.Delta) {
            return parseDeltaOrDiffExpr();
        }
        throw new ParseError(`program must start with date or delta`);
    }

    function parseDateExpr(): DateCalcNode {
        let date = stream.expect(TokenType.Date) as DateToken;
        let nextToken = stream.peek();
        if (nextToken) {
            if (nextToken.tokenType == TokenType.Plus || nextToken.tokenType == TokenType.Minus) {
                let opToken = stream.next();
                let delta = parseDeltaOrDiffExpr();
                return new BinaryOpNode(opToken, date, delta);
            }
            throw new ParseError(`unexpected token: ${nextToken}`);
        }
        return date;
    }

    function parseDeltaOrDiffExpr(): DateCalcNode {
        let token = stream.peek();
        if (!token) {
            throw new ParseError(`incomplete expression: missing date or delta`);
        }
        if (token.tokenType == TokenType.Delta) {
            return parseDeltaExpr();
        } else if (token.tokenType == TokenType.Date) {
            return parseDateDiff();
        }
        throw new ParseError(`expected delta or date but got: ${token}`);
    }

    function parseDeltaExpr(): DateCalcNode {
        let delta = stream.expect(TokenType.Delta) as DeltaToken;
        let nextToken = stream.peek();
        if (nextToken) {
            if (nextToken.tokenType == TokenType.Plus || nextToken.tokenType == TokenType.Minus) {
                let opToken = stream.next();
                let rightDelta = parseDeltaOrDiffExpr();
                return new BinaryOpNode(opToken, delta, rightDelta);
            }
            throw new ParseError(`unexpected token: ${nextToken}`);
        }
        return delta;
    }

    function parseDateDiff(): DateCalcNode {
        let date = stream.expect(TokenType.Date) as DateToken;
        let op = stream.expect(TokenType.Minus);
        let delta = parseDeltaExpr();
        return new BinaryOpNode(op, date, delta);

    }

    let result = parseProgram();
    if (stream.hasNext()) {
        throw new ParseError(`unexpected tokens after program end: ${tokens.splice(stream.index + 1)}`);
    }
    return result;
}

try {
    let tokens = tokenize("12/34/56-1 day+23 hours");
    console.log(tokens);
    let nodes = parse(tokens);
    console.log(nodes);
} catch (ex) {
    console.error(ex);
}
