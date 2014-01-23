package particledsl.tokens;

import particledsl.*;

public class BinaryCompareToken extends BinaryMathToken implements BooleanToken
{
    public BinaryCompareToken(String op)
    {
        super(op);
    }

    @Override
    public int lbp()
    {
        return 40;
    }
}
