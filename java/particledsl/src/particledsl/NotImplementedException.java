package particledsl;

public class NotImplementedException extends UnsupportedOperationException
{
    public NotImplementedException()
    {
        this("");
    }

    public NotImplementedException(String message)
    {
        super(message);
    }
}
