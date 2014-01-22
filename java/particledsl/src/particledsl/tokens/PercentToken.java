package particledsl.tokens;

import particledsl.*;

public class PercentToken extends Token
{
    public Token left, right;

    public PercentToken()
    {
        super("%");
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
        return "(% " + this.left + " " + this.right + ")";
    }
}
