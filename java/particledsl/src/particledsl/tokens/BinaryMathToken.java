package particledsl.tokens;

import particledsl.*;

public class BinaryMathToken extends Token
{
    public Token left, right;

    public BinaryMathToken(String value)
    {
        super(value);
    }

    @Override
    public Token led(Parser p, Token left)
    {
        this.left = left;
        this.right = p.expression(lbp());
        return this;
    }

    @Override
    public String toString()
    {
        return "(" + tokenValue() + " " + this.left + " " + this.right + ")";
    }
}
