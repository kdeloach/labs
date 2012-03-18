import javax.swing.JComponent;
import javax.swing.BorderFactory;

import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Color;

public class Deposit extends JComponent  implements MouseListener
{
    private static final long serialVersionUID = 1L;

    public Color bg = Color.LIGHT_GRAY;
    public Color outLine = Color.GRAY;

    boolean mousePressed,mouseEntered;

    public Deposit()
    {
        super();

        enableInputMethods(true);
        addMouseListener(this);

        setBorder(BorderFactory.createLoweredBevelBorder());
        setFocusable(true);
    }
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);

        g.setColor(bg);
        g.fillRect(0, 0, getWidth() - 1, getHeight() - 1);

        g.setColor(outLine);
        g.drawRect(0,0,getWidth() - 1, getHeight() - 1);
    }
    public void mouseClicked(MouseEvent e)
    {
    }
    public void mouseEntered(MouseEvent e)
    {
        mouseEntered = true;
        repaint();
    }
    public void mouseExited(MouseEvent e)
    {
        mouseEntered = false;
        repaint();
    }
    public void mousePressed(MouseEvent e)
    {
        mousePressed = true;
        repaint();
    }
    public void mouseReleased(MouseEvent e)
    {
        mousePressed = false;
        repaint();
    }
    public Dimension getPreferredSize()
    {
        return new Dimension(getWidth(),getHeight());
    }
    public Dimension getMinimumSize()
    {
        return getPreferredSize();
    }
    public Dimension getMaximumSize()
    {
        return getPreferredSize();
    }
}
