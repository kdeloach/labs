package particledsl.tokens;

import particledsl.*;

public class LogicalOpToken extends BinaryMathToken implements BooleanToken
{
    public LogicalOpToken(String op)
    {
        super(op);
    }

    @Override
    public Token led(Parser p, Token left)
    {
        this.left = left;
        if (!(this.left instanceof BooleanToken)) {
            throw new SyntaxErrorException("Boolean expression expected on left side of '" + tokenValue() + "'");
        }
        this.right = p.expression(lbp());
        if (!(this.right instanceof BooleanToken)) {
            throw new SyntaxErrorException("Boolean expression expected on right side of '" + tokenValue() + "'");
        }
        return this;
    }

    @Override
    public int lbp()
    {
        return 30;
    }
}
