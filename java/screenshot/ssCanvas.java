import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssCanvas extends JPanel implements Runnable {
    // Panel dimensions
    final static int WIDTH = 600;
    final static int HEIGHT = 500;

    // Selected color
    Color color;

    // Selected tool
    ssTool tool;

    // All drawing is done to this image
    BufferedImage paper;

    // Canvas background image
    Image background;

    public ssCanvas() {
        super();

        setBackground(Color.WHITE);

        // Create a new thread to draw the canvas
        // this executes the run() method
        new Thread(this).start();
        setIgnoreRepaint(true);

        paper = new BufferedImage(1, 1, BufferedImage.TYPE_INT_BGR);
        paper.createGraphics();

        background = new BufferedImage(1, 1, BufferedImage.TYPE_INT_BGR);
        clear();
    }

    public Dimension getPreferredSize() {
        return new Dimension(background.getWidth(this), background.getHeight(this));
    }

    // This launches in its own thread, repaints the canvas every 1ms
    public void run() {
        while(true) {
            try {
                Thread.sleep(10);
            } catch (Exception ie) {
                return;
            }
            repaint();
        }
    }

    public void setTool(ssTool t) {
        if (tool != null){
            removeMouseListener(tool);
            removeMouseMotionListener(tool);
        }
        tool = t;
        addMouseListener(tool);
        addMouseMotionListener(tool);
    }

    public void paint(Graphics g) {
        Graphics g2d = (Graphics2D)paper.getGraphics();
        g2d.setColor(color);
        if (tool != null) {
            tool.paintCanvas(g2d);
        }
        g.drawImage(paper, 0, 0, getWidth(), getHeight(), this);
    }

    public void setBackground(Image bg) {
        background = bg;
        setSize(bg.getWidth(this), bg.getHeight(this));

        paper = new BufferedImage(getWidth(), getHeight(), BufferedImage.TYPE_INT_BGR);
        paper.createGraphics();

        invalidate();
        clear();
    }

    public void clear() {
        Graphics g = (Graphics2D)paper.getGraphics();
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, getWidth(), getHeight());
        g.drawImage(background, 0, 0, getWidth(), getHeight(), this);
    }
}