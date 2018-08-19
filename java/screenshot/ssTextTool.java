import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssTextTool extends ssTool {
    Point m;
    Point last;
    JToggleButton btn;

    public ssTextTool() {
    }

    public void activate() {
        m = null;
        last = null;
    }

    public void mouseDragged(MouseEvent e) {
    }

    public void mouseReleased(MouseEvent e) {
    }

    public void paintCanvas(Graphics g) {
    }

    public JToggleButton getButton() {
        if (btn != null) {
            return btn;
        }
        btn = new JToggleButton("T"){};
        return btn;
    }
}