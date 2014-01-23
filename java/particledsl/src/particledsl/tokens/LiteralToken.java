package particledsl.tokens;

import particledsl.*;

public class LiteralToken extends Token
{
    public LiteralToken(String value)
    {
        super(value);
    }

    @Override
    public String toString()
    {
        return "(literal '" + tokenValue() + "')";
    }
}
