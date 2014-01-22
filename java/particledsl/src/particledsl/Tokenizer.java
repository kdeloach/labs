package particledsl;

import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import particledsl.tokens.*;

public class Tokenizer implements Iterator<Token>, Iterable<Token>
{
    final static Token WHITESPACE = new WhitespaceToken();

    Matcher matcher;

    public Tokenizer(String input)
    {
        matcher = getPattern().matcher(input);
    }

    public static Pattern getPattern()
    {
        StringBuilder sb = new StringBuilder();
        sb.append("(?:");
        sb.append("(?<op>\\(|\\)|<=|>=|!==|==|[%!\\-+,></*])");
        sb.append("|(?<ident>[a-zA-Z][a-zA-Z0-9]*)");
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
                case "%": return new PercentToken();
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
