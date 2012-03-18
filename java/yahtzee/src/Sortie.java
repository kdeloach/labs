public class Sortie
{
    public int val,ID;
    public String caption;

    public Sortie(String caption, int val, int ID)
    {
        this.ID = ID;
        this.val = val;
        this.caption = caption;
    }
    public String toString()
    {
        return new String(caption+" ("+val+")");
    }
}
