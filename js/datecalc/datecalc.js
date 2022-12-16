enum TokenType {
    Number = "NUMBER",
    Unit = "UNIT",
    Slash = "SLASH",
    Plus = "PLUS",
    Minus = "MINUS",
    As = "AS",
}

enum UnitType {
    Second = "SECOND",
    Minute = "MINUTE",
    Hour = "HOUR",
    Day = "DAY",
    Week = "WEEK",
    Month = "MONTH",
    Year = "YEAR",
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

    let units: {[key: string]: UnitType} = {
        "second": UnitType.Second,
        "minute": UnitType.Minute,
        "hour": UnitType.Hour,
        "day": UnitType.Day,
        "week": UnitType.Week,
        "month": UnitType.Month,
        "year": UnitType.Year,
    };

    for(let k in units) {
        units[k + "s"] = units[k];
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
            let word = scanWord().toLowerCase();
            if (word == "as") {
                tokens.push(new Token(TokenType.As));
            } else if (word in units) {
                tokens.push(new Token(TokenType.Unit, units[word]));
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
        let token = stream.expect(TokenType.Number);
        if (stream.hasNext()) {
            let nextToken = stream.peek();
            if (nextToken.tokenType == TokenType.Slash) {
                return parseDate();
            } else if (nextToken.tokenType == TokenType.Unit) {
                return parseDelta();
            }
            throw new ParseError(`unexpected token: ${nextToken}`);
        }
        return token; // ???
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
                let unit = stream.expect(TokenType.Unit);
                return new CastNode(left, unit);
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

///

const SECOND = 1000;
const MINUTE = SECOND * 60;
const HOUR = MINUTE * 60;
const DAY = HOUR * 24;
const WEEK = DAY * 7;
const MONTH = DAY * 30.436875;
const YEAR = DAY * 365.25;

class Delta {
    constructor(public amount: number, public unit: UnitType) {
    }

    getConversionFactor(): number {
        switch (this.unit) {
            case UnitType.Second: return SECOND;
            case UnitType.Minute: return MINUTE;
            case UnitType.Hour: return HOUR;
            case UnitType.Day: return DAY;
            case UnitType.Week: return WEEK;
            case UnitType.Month: return MONTH;
            case UnitType.Year: return YEAR;
            default: throw new ParseError(`unexpected unit: ${this.unit}`);
        }
    }

    toString(): string {
        let unit = this.unit.toLowerCase();
        if (this.amount != 1) {
            unit += "s";
        }
        return `${this.amount} ${unit}`;
    }
}

function resolve(node: DateCalcNode) {
    function visit(node: DateCalcNode): Date | Delta {
        if (node instanceof DateNode) {
            return visitDateNode(node);
        } else if (node instanceof DeltaNode) {
            return visitDeltaNode(node);
        } else if (node instanceof PlusNode) {
            return visitPlusNode(node);
        }
        throw new ParseError(`unexpected node: ${node}`);
    }

    function visitDateNode(date: DateNode): Date {
        let m = parseInt(date.m.value, 10);
        let d = parseInt(date.d.value, 10);
        let y = parseInt(date.y.value, 10);
        return new Date(y, m - 1, d);
    }

    function visitDeltaNode(delta: DeltaNode): Delta {
        let amount = parseInt(delta.amount.value, 10);
        let unit = delta.unit.value as UnitType;
        return new Delta(amount, unit);
    }

    function visitPlusNode(op: PlusNode): Date | Delta {
        let left = visit(op.left);
        let right = visit(op.right);
        if (left instanceof Date && right instanceof Date) {
            throw new ParseError(`adding dates is not supported`);
        } else if (left instanceof Date && right instanceof Delta) {
            return datePlusDelta(left, right);
        } else if (left instanceof Delta && right instanceof Date) {
            return datePlusDelta(right, left);
        } else if (left instanceof Delta && right instanceof Delta) {
            return deltaPlusDelta(left, right);
        }
        throw new ParseError(`expected date or delta but got: ${left} and ${right}`);
    }

    function datePlusDelta(date: Date, delta: Delta): Date {
        let ms = delta.amount * delta.getConversionFactor();
        return new Date(date.getTime() + ms);
    }

    function deltaPlusDelta(left: Delta, right: Delta): Delta {     
        let leftAmount = left.amount * (left.getConversionFactor() / right.getConversionFactor());
        return new Delta(leftAmount + right.amount, right.unit);
    }

    return visit(node);
}

try {
    let tokens = tokenize("1 day + 1 second + 0 day");
    console.log(tokens);
    let node = parse(tokens);
    console.log(node);
    let result = resolve(node);
    console.log(result.toString());
} catch (ex) {
    console.error(ex);
}
