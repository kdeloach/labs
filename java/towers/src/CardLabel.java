import javax.swing.JLabel;
import java.awt.Font;
import java.awt.Dimension;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Graphics;

// CardLayout will resize itself based on its value
// The bigger the number, the greater the width
public class CardLabel extends JLabel
{
    private static final long serialVersionUID = 1L;

    // Maximum width of label
    static final int MAX_WIDTH = 50;

    boolean highlighted=false;

    public CardLabel(String label)
    {
        super(label);
        setHorizontalAlignment(CENTER);
        setAlignmentX(CENTER_ALIGNMENT);
        this.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        setBackground(new Color(0xC3, 0xD9, 0xFF));
        setFont(new Font("Dialog", Font.PLAIN, 24));
    }

    public Dimension getPreferredSize()
    {
        Dimension d = super.getPreferredSize();
        int v = new Integer(getText());
        double p = v / (double)Main.AMT_CARDS;
        d.width = (int)(d.width + p * MAX_WIDTH + 10);
        return d;
    }

    public Dimension getMinimumSize()
    {
        return getPreferredSize();
    }

    public Dimension getMaximumSize()
    {
        return getPreferredSize();
    }

    public Color getCustomBackgroundColor()
    {
        int r = (int)(getBackground().getRed()/2);
        int g = (int)(getBackground().getGreen()/2);
        int b = (int)(getBackground().getBlue()/2);

        int v = new Integer(getText());
        double p = v / (double)Main.AMT_CARDS;

        Color c = new Color(
            (int)(3 * r - (r * p + r)),
            (int)(3 * g - (g * p + g)),
            (int)(3 * b - (b * p + b))
        );

        return c;
    }

    public void paintComponent(Graphics g)
    {
        Color bg = getCustomBackgroundColor();

        // Applet Background color
        g.setColor(new Color(0xE0, 0xEC, 0xFF));
        g.fillRect(0, 0, getWidth(), getHeight());

        // Card Background
        g.setColor(bg);
        g.fillRoundRect(0, 0, getWidth(), getHeight(), 10, 10);

        // Text
        super.paintComponent(g);

        // Highlight Overlay
        if(isHighlighted())
        {
            Color overlay = new Color(0xff, 0xff, 0xff, 127);
            g.setColor(overlay);
            g.fillRoundRect(0, 0, getWidth(), getHeight(), 10, 10);
        }
    }

    public boolean isHighlighted()
    {
        return highlighted;
    }

    public void setHighlight(boolean highlight)
    {
        this.highlighted = highlight;
    }
}
