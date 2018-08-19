import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssSnapshotTool extends ssTool {
    double scale = 0.80;

    BufferedImage snapshot;
    KeyListener listener;
    JToggleButton btn;

    public ssSnapshotTool() {
        listener = new KeyListener() {
            public void keyReleased(KeyEvent e) {
                System.out.println(e);
            }
            public void keyTyped(KeyEvent e) {
                System.out.println(e);
            }
            public void keyPressed(KeyEvent e) {
                System.out.println(e);
            }
        };
    }

    public void activate() {
        System.out.println("Activated" + window);
        window.addKeyListener(listener);
    }

    public void deactivate() {
        System.out.println("Deactivated");
        window.removeKeyListener(listener);
    }

    public void screencap() {
        Toolkit toolkit = Toolkit.getDefaultToolkit();
        Dimension screenSize = toolkit.getScreenSize();
        Rectangle screenRect = new Rectangle(screenSize);
        try {
            Robot robot = new Robot();
            BufferedImage image = robot.createScreenCapture(screenRect);
        } catch (Exception ie) {
            System.out.println("Error");
        }
    }

    public JToggleButton getButton() {
        if (btn != null) {
            return btn;
        }

        btn = new JToggleButton("S"){};
        return btn;
    }
}