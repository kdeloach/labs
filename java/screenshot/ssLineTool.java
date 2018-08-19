import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssLineTool extends ssTool {
    int strokeSize = 4;

    Point m;
    Point last;
    JToggleButton btn;

    public ssLineTool() {
    }

    public void activate() {
        m = null;
        last = null;
    }

    public void mousePressed(MouseEvent e) {
        last = e.getPoint();
    }
    public void mouseReleased(MouseEvent e) {
        m = e.getPoint();
    }

    public void paintCanvas(Graphics g) {
        if (m == null || last == null) {
            return;
        }

        Graphics2D g2d = (Graphics2D)g;
        g2d.setStroke(new BasicStroke(strokeSize));
        g2d.drawLine(last.x, last.y, m.x, m.y);

        last = null;
        m = null;
    }

    public JToggleButton getButton() {
        if (btn != null) {
            return btn;
        }
        btn = new JToggleButton("L"){};
        return btn;
    }
}