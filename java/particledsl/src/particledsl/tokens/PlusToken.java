package particledsl.tokens;

import particledsl.*;

public class PlusToken extends BinaryMathToken
{
    public Token left, right;

    public PlusToken()
    {
        super("+");
    }

    @Override
    public int lbp()
    {
        return 50;
    }
}
