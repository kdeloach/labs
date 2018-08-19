import javax.swing.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssToolbar extends JPanel {
    ssCanvas canvas;

    public ssToolbar() {
        super();
    }

    public void setCanvas(ssCanvas c) {
        canvas = c;
        updateSelection();
    }

    public void updateSelection() {
    }
}