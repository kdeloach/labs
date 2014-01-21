package particledsl.tokens;

import particledsl.*;

public class SlashToken extends Token
{
    Token left, right;

    public SlashToken()
    {
        super("/");
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
        return "(/ " + this.left + " " + this.right + ")";
    }
}
