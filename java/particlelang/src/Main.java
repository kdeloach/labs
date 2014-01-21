import java.util.Arrays;
import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class Main
{
    public static void main(String[] argv)
    {
        StringBuilder sb = new StringBuilder();
        sb.append("(?:");
        sb.append("(?<op>\\(|\\)|<=|>=|!==|==|[!\\-+,></*])");
        sb.append("|(?<ident>[a-z][a-z0-9]+)");
        sb.append("|(?<number>\\d+(?:\\.\\d+)?)");
        sb.append("|(?<whitespace>[\n\t ])");
        sb.append("|(?<unknown>.)");
        sb.append(")");
        Pattern p = Pattern.compile(sb.toString());
        String[] samplePrograms = new String[] {
            "2*7-1",
            "2*(7-1)"
        };
        for (String input : Arrays.asList(samplePrograms)) {
            System.out.println(input);
            Parser parser = new Parser(new Tokenizer(p, input));
            System.out.println(parser.expression(0));
        }
    }
}

class Tokenizer implements Iterator<Token>
{
    final static Token WHITESPACE = new WhitespaceToken();

    Matcher matcher;

    public Tokenizer(Pattern pattern, String input)
    {
        matcher = pattern.matcher(input);
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
            throw new UnsupportedOperationException("Not implemented");
        } else if (matcher.group("whitespace") != null) {
            return WHITESPACE;
        } else {
            throw new UnsupportedOperationException("Syntax Error");
        }
    }

    public void remove()
    {
        throw new UnsupportedOperationException("Not implemented");
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
        return next("");
    }

    public Token next(String expectValue)
    {
        while (tokenizer.hasNext()) {
            currentToken = tokenizer.next();
            if (currentToken.isWhitespace()) {
                continue;
            }
            if (expectValue.length() > 0 && currentToken.tokenValue() != expectValue) {
                throw new UnsupportedOperationException("Expected " + expectValue + " but got " + currentToken.tokenValue());
            }
            return currentToken;
        }
        currentToken = new EndProgramToken();
        return currentToken;
    }

    // Author: Fredrik Lundh
    // Source: http://effbot.org/zone/simple-top-down-parsing.htm
    public Token expression(int rbp)
    {
        Token currentToken = current();
        Token nextToken = next();
        Token left = currentToken.nud(this);
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
        return 0;
    }

    public Token nud(Parser p)
    {
        throw new UnsupportedOperationException("Not implemented (" + tokenValue() + ")");
    }

    public Token led(Parser p, Token left)
    {
        throw new UnsupportedOperationException("Not implemented (" + tokenValue() + ")");
    }

    public boolean isWhitespace()
    {
        return false;
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

class LParenToken extends Token
{
    public LParenToken()
    {
        super("(");
    }

    @Override
    public Token nud(Parser p)
    {
        Token result = p.expression(0);
        p.next(")");
        return result;
    }
}

class RParenToken extends Token
{
    public RParenToken()
    {
        super(")");
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
