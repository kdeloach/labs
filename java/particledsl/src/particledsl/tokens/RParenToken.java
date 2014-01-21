package particledsl.tokens;

import particledsl.*;

public class RParenToken extends Token
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
