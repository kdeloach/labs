package particledsl.tokens;

import particledsl.*;

public class SlashToken extends BinaryMathToken
{
    public SlashToken()
    {
        super("/");
    }

    @Override
    public int lbp()
    {
        return 60;
    }
}
