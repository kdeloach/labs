package particledsl;

import particledsl.tokens.Token;
import particledsl.tokens.EndProgramToken;

public class Parser
{
    Tokenizer tokenizer;
    Token currentToken;

    public Parser(Tokenizer tokenizer)
    {
        this.tokenizer = tokenizer;
        next();
    }

    public Token current()
    {
        return currentToken;
    }

    public Token next()
    {
        while (tokenizer.hasNext()) {
            currentToken = tokenizer.next();
            if (currentToken.isWhitespace()) {
                continue;
            }
            return currentToken;
        }
        currentToken = new EndProgramToken();
        return currentToken;
    }

    public Token expect(String expectedValue)
    {
        if (!currentToken.tokenValue().equals(expectedValue)) {
            throw new SyntaxErrorException("Expected '" + expectedValue + "' but got '" + currentToken.tokenValue() + "'");
        }
        return next();
    }

    public Token parse()
    {
        Token program = expression(0);
        expect("<end>");
        return program;
    }

    // Author: Fredrik Lundh
    // Source: http://effbot.org/zone/simple-top-down-parsing.htm
    public Token expression(int rbp)
    {
        Token currentToken = current();
        Token nextToken = next();
        Token left = currentToken.nud(this);
        // Sub-expressions may eat tokens so keep our local references up to date
        nextToken = current();
        while (rbp < nextToken.lbp()) {
            currentToken = current();
            nextToken = next();
            left = currentToken.led(this, left);
            // Sub-expressions may eat tokens so keep our local references up to date
            nextToken = current();
        }
        return left;
    }
}
