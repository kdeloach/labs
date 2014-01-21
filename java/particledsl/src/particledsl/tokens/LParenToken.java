package particledsl.tokens;

import particledsl.*;

public class LParenToken extends Token
{
    public LParenToken()
    {
        super("(");
    }

    @Override
    public Token nud(Parser p)
    {
        Token expr = p.expression(lbp());
        p.expect(")");
        return expr;
    }

    @Override
    public Token led(Parser p, Token left)
    {
        if (left instanceof IdentToken) {
            return new CallFuncToken((IdentToken)left).nud(p);
        }
        throw new SyntaxErrorException("Object cannot be invoked");
    }
}
