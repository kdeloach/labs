import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssEraseTool extends ssTool {
    int strokeSize = 10;

    Point m;
    Point last;
    JToggleButton btn;

    public ssEraseTool() {
    }

    public void activate() {
        m = null;
        last = null;
    }

    public void mouseDragged(MouseEvent e) {
        last = m;
        m = e.getPoint();
    }
    public void mouseReleased(MouseEvent e) {
        m = null;
        last = null;
    }

    public void paintCanvas(Graphics g) {
        if (m == null || last == null) {
            return;
        }

        Graphics2D g2d = (Graphics2D)g;
        g2d.setStroke(new BasicStroke(strokeSize));
        g2d.drawLine(last.x, last.y, m.x, m.y);
    }

    public JToggleButton getButton() {
        if (btn != null) {
            return btn;
        }
        btn = new JToggleButton("E"){};
        return btn;
    }
}