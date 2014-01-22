package particledsl.tokens;

import particledsl.*;

public class PercentToken extends BinaryMathToken
{
    public Token left, right;

    public PercentToken()
    {
        super("%");
    }

    @Override
    public int lbp()
    {
        return 60;
    }
}
