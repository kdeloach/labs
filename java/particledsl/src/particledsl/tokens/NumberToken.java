package particledsl.tokens;

import particledsl.*;

public class NumberToken extends Token
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
