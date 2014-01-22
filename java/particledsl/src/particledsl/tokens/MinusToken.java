package particledsl.tokens;

import particledsl.*;

public class MinusToken extends BinaryMathToken
{
    public MinusToken()
    {
        super("-");
    }

    @Override
    public int lbp()
    {
        return 50;
    }
}
