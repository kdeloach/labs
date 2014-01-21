package particledsl.tokens;

import particledsl.*;

public class WhitespaceToken extends Token
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
