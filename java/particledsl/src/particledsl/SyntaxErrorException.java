package particledsl;

public class SyntaxErrorException extends UnsupportedOperationException
{
    public SyntaxErrorException()
    {
        this("");
    }

    public SyntaxErrorException(String message)
    {
        super(message);
    }
}
