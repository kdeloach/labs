package particledsl.tokens;

import particledsl.*;

public class StarToken extends BinaryMathToken
{
    public StarToken()
    {
        super("*");
    }

    @Override
    public int lbp()
    {
        return 60;
    }
}
