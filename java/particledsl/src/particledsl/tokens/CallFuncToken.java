package particledsl.tokens;

import particledsl.*;

public class CallFuncToken extends Token
{
    public IdentToken ident;
    public ArgsListToken args;

    public CallFuncToken(IdentToken ident)
    {
        super("<function>");
        this.ident = ident;
    }

    @Override
    public Token nud(Parser p)
    {
        args = (ArgsListToken)new ArgsListToken().nud(p);
        p.expect(")");
        return this;
    }

    @Override
    public String toString()
    {
        return "(func " + this.ident + " " + this.args + ")";
    }
}
