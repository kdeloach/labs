package particledsl.tokens;

import particledsl.*;

public class IdentToken extends Token
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
