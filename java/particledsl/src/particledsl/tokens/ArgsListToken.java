package particledsl.tokens;

import java.util.LinkedList;
import particledsl.*;

public class ArgsListToken extends Token
{
    public LinkedList<Token> args;

    public ArgsListToken()
    {
        super("<args>");
    }

    @Override
    public Token nud(Parser p)
    {
        args = new LinkedList<Token>();
        while (p.current().tokenValue() != ")") {
            Token expr = p.expression(0);
            args.add(expr);
            if (p.current().tokenValue() != ")") {
                p.expect(",");
            }
        }
        return this;
    }

    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        for (Token t : args) {
            sb.append(t.toString());
            sb.append(" ");
        }
        return "(args " + sb.toString().trim() + ")";
    }
}
