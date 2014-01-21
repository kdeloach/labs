package particledsl.tokens;

import particledsl.*;

public class EndProgramToken extends Token
{
    public EndProgramToken()
    {
        super("END");
    }

    @Override
    public int lbp()
    {
        return 0;
    }

    @Override
    public String toString()
    {
        return "(end program)";
    }
}
