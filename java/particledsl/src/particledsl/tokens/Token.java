package particledsl.tokens;

import particledsl.*;

public abstract class Token
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
        return "(token '" + tokenValue() + "')";
    }
}
