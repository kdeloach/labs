import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssClearTool extends ssTool {
    JToggleButton btn;

    public ssClearTool() {
    }

    public void activate() {
        canvas.clear();
    }

    public JToggleButton getButton() {
        if (btn != null) {
            return btn;
        }
        btn = new JToggleButton("C"){};
        return btn;
    }
}