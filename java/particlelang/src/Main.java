import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class Main
{
    public static void main(String[] argv)
    {
        String[] samplePrograms = new String[] {
            //"random(1, 360) * pi / 180",
            "random() * 0x55 + 0x33"
        };
        for (String input : Arrays.asList(samplePrograms)) {
            System.out.println(input);
            Parser parser = new Parser(new Tokenizer(input));
            System.out.println(parser.expression(0));
        }
    }
}

class SyntaxErrorException extends UnsupportedOperationException
{
    public SyntaxErrorException()
    {
        this("");
    }

    public SyntaxErrorException(String message)
    {
        super(message);
    }
}

class NotImplementedException extends UnsupportedOperationException
{
    public NotImplementedException()
    {
        this("");
    }

    public NotImplementedException(String message)
    {
        super(message);
    }
}

class Tokenizer implements Iterator<Token>, Iterable<Token>
{
    final static Token WHITESPACE = new WhitespaceToken();

    Matcher matcher;

    public Tokenizer(String input)
    {
        matcher = getPattern().matcher(input);
    }

    public Pattern getPattern()
    {
        StringBuilder sb = new StringBuilder();
        sb.append("(?:");
        sb.append("(?<op>\\(|\\)|<=|>=|!==|==|[!\\-+,></*])");
        sb.append("|(?<ident>[a-zA-Z][a-zA-Z0-9]+)");
        sb.append("|(?<number>(?:0x[a-fA-F0-9]+|\\d+(?:\\.\\d+)?))");
        sb.append("|(?<whitespace>[\n\t ])");
        sb.append("|(?<unknown>.)");
        sb.append(")");
        return Pattern.compile(sb.toString());
    }

    public boolean hasNext()
    {
        return matcher.find();
    }

    public Token next()
    {
        if (matcher.group("number") != null) {
            return new NumberToken(matcher.group());
        } else if (matcher.group("ident") != null) {
            return new IdentToken(matcher.group());
        } else if (matcher.group("op") != null) {
            switch (matcher.group("op")) {
                case "+": return new PlusToken();
                case "-": return new MinusToken();
                case "*": return new StarToken();
                case "/": return new SlashToken();
                case "(": return new LParenToken();
                case ")": return new RParenToken();
            }
            return new LiteralToken(matcher.group());
        } else if (matcher.group("whitespace") != null) {
            return WHITESPACE;
        } else {
            throw new SyntaxErrorException(matcher.group());
        }
    }

    public void remove()
    {
        throw new NotImplementedException();
    }

    public Iterator<Token> iterator()
    {
        return this;
    }
}

class Parser
{
    Tokenizer tokenizer;
    Token currentToken;

    public Parser(Tokenizer tokenizer)
    {
        this.tokenizer = tokenizer;
        next();
    }

    public Token current()
    {
        return currentToken;
    }

    public Token next()
    {
        while (tokenizer.hasNext()) {
            currentToken = tokenizer.next();
            if (currentToken.isWhitespace()) {
                continue;
            }
            return currentToken;
        }
        currentToken = new EndProgramToken();
        return currentToken;
    }

    public Token expect(String expectedValue)
    {
        if (!currentToken.tokenValue().equals(expectedValue)) {
            throw new SyntaxErrorException("Expected '" + expectedValue + "' but got '" + currentToken.tokenValue() + "'");
        }
        return next();
    }

    // Author: Fredrik Lundh
    // Source: http://effbot.org/zone/simple-top-down-parsing.htm
    public Token expression(int rbp)
    {
        Token currentToken = current();
        Token nextToken = next();
        Token left = currentToken.nud(this);
        // Sub-expressions may eat tokens so keep our local references up to date
        nextToken = current();
        while (rbp < nextToken.lbp()) {
            currentToken = current();
            nextToken = next();
            left = currentToken.led(this, left);
            // Sub-expressions may eat tokens so keep our local references up to date
            nextToken = current();
        }
        return left;
    }
}

abstract class Token
{
    private String value;

    public Token(String value)
    {
        this.value = value;
    }

    public String tokenValue()
    {
        return value;
    }

    public int lbp()
    {
        return 1;
    }

    public Token nud(Parser p)
    {
        throw new NotImplementedException("Not implemented (" + tokenValue() + ")");
    }

    public Token led(Parser p, Token left)
    {
        throw new NotImplementedException("Not implemented (" + tokenValue() + ")");
    }

    public boolean isWhitespace()
    {
        return false;
    }

    @Override
    public String toString()
    {
        return "Token('" + tokenValue() + "')";
    }
}

class LiteralToken extends Token
{
    public LiteralToken(String value)
    {
        super(value);
    }

    @Override
    public String toString()
    {
        return "(literal " + tokenValue() + ")";
    }
}

class NumberToken extends Token
{
    public NumberToken(String value)
    {
        super(value);
    }

    @Override
    public Token nud(Parser p)
    {
        return this;
    }

    @Override
    public String toString()
    {
        return "(number " + tokenValue() + ")";
    }
}

class IdentToken extends Token
{
    public IdentToken(String value)
    {
        super(value);
    }

    @Override
    public Token nud(Parser p)
    {
        return this;
    }

    @Override
    public String toString()
    {
        return "(ident " + tokenValue() + ")";
    }
}

class PlusToken extends Token
{
    Token left, right;

    public PlusToken()
    {
        super("+");
    }

    @Override
    public Token led(Parser p, Token left)
    {
        this.left = left;
        this.right = p.expression(lbp());
        return this;
    }

    @Override
    public int lbp()
    {
        return 50;
    }

    @Override
    public String toString()
    {
        return "(+ " + this.left + " " + this.right + ")";
    }
}

class MinusToken extends Token
{
    Token left, right;

    public MinusToken()
    {
        super("-");
    }

    @Override
    public Token led(Parser p, Token left)
    {
        this.left = left;
        this.right = p.expression(lbp());
        return this;
    }

    @Override
    public int lbp()
    {
        return 50;
    }

    @Override
    public String toString()
    {
        return "(- " + this.left + " " + this.right + ")";
    }
}

class StarToken extends Token
{
    Token left, right;

    public StarToken()
    {
        super("*");
    }

    @Override
    public Token led(Parser p, Token left)
    {
        this.left = left;
        this.right = p.expression(lbp());
        return this;
    }

    @Override
    public int lbp()
    {
        return 60;
    }

    @Override
    public String toString()
    {
        return "(* " + this.left + " " + this.right + ")";
    }
}

class SlashToken extends Token
{
    Token left, right;

    public SlashToken()
    {
        super("/");
    }

    @Override
    public Token led(Parser p, Token left)
    {
        this.left = left;
        this.right = p.expression(lbp());
        return this;
    }

    @Override
    public int lbp()
    {
        return 60;
    }

    @Override
    public String toString()
    {
        return "(/ " + this.left + " " + this.right + ")";
    }
}

class CallFuncToken extends Token
{
    public IdentToken ident;
    public ArgsListToken args;

    public CallFuncToken(IdentToken ident)
    {
        super("<function>");
        this.ident = ident;
    }

    @Override
    public Token nud(Parser p)
    {
        args = (ArgsListToken)new ArgsListToken().nud(p);
        p.expect(")");
        return this;
    }

    @Override
    public String toString()
    {
        return "(func " + this.ident + " " + this.args + ")";
    }
}

class ArgsListToken extends Token
{
    public List<Token> args;

    public ArgsListToken()
    {
        super("<args>");
    }

    @Override
    public Token nud(Parser p)
    {
        args = new LinkedList<Token>();
        while (p.current().tokenValue() != ")") {
            Token expr = p.expression(lbp());
            args.add(expr);
            if (p.current().tokenValue() != ")") {
                p.expect(",");
            }
        }
        return this;
    }

    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        for (Token t : args) {
            sb.append(t.toString());
            sb.append(" ");
        }
        return "(args " + sb.toString().trim() + ")";
    }
}

class LParenToken extends Token
{
    public LParenToken()
    {
        super("(");
    }

    @Override
    public Token nud(Parser p)
    {
        Token expr = p.expression(lbp());
        p.expect(")");
        return expr;
    }

    @Override
    public Token led(Parser p, Token left)
    {
        if (left instanceof IdentToken) {
            return new CallFuncToken((IdentToken)left).nud(p);
        }
        throw new SyntaxErrorException("Object cannot be invoked");
    }
}

class RParenToken extends Token
{
    public RParenToken()
    {
        super(")");
    }

    @Override
    public Token led(Parser p, Token left)
    {
        throw new SyntaxErrorException("Missing left parenthesis");
    }
}

class WhitespaceToken extends Token
{
    public WhitespaceToken()
    {
        super("");
    }

    @Override
    public boolean isWhitespace()
    {
        return true;
    }
}

class EndProgramToken extends Token
{
    public EndProgramToken()
    {
        super("END");
    }

    @Override
    public int lbp()
    {
        return 0;
    }

    @Override
    public String toString()
    {
        return "(end program)";
    }
}
