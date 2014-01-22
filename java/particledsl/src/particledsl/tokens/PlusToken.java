package particledsl.tokens;

import particledsl.*;

public class PlusToken extends Token
{
    public Token left, right;

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
