import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public abstract class ssTool extends MouseInputAdapter {
    ssCanvas canvas;
    JFrame window;

    public ssTool() {
    }

    public void paintCanvas(Graphics g) {
    }

    public void activate() {
    }

    public void deactivate() {
    }

    public void setCanvas(ssCanvas c) {
        canvas = c;
    }

    public abstract JToggleButton getButton();
}