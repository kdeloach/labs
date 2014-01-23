package particledsl.tokens;

import particledsl.*;

public class TrueFalseToken extends Token implements BooleanToken
{
    public TrueFalseToken(String value)
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
        return "(" + tokenValue() + ")";
    }
}
