package particledsl.tokens;

import particledsl.*;

public class CondToken extends Token
{
    public Token cond, trueBody, otherBody;

    public CondToken()
    {
        super("if");
    }

    @Override
    public Token nud(Parser p)
    {
        p.expect("(");
        cond = p.expression(0);
        if (!(cond instanceof BooleanToken)) {
            throw new SyntaxErrorException("Boolean expression expected here");
        }
        p.expect(")");
        trueBody = p.expression(0);
        p.expect("else");
        if (p.current().tokenValue().equals("if")) {
            p.expect("if");
            otherBody = (Token)new CondToken().nud(p);
        } else {
            otherBody = p.expression(0);
        }
        return this;
    }

    @Override
    public String toString()
    {
        return "(if " + cond + " " + trueBody + " " + otherBody + ")";
    }
}
