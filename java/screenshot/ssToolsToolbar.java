import javax.swing.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssToolsToolbar extends ssToolbar {
    final static int BTN_WIDTH = 45;
    final static int BTN_HEIGHT = 45;

    public ssTool[] tools = new ssTool[] {
        new ssPenTool(),
        new ssEraseTool(),
        new ssTextTool(),
        new ssClearTool(),
        new ssLineTool()
    };
    ssTool lastTool = null;

    JToggleButton dummy;
    ButtonGroup bg;
    JFrame window;

    public ssToolsToolbar(JFrame w){
        super();

        window = w;
        bg = new ButtonGroup();

        // this never gets used
        dummy = new JToggleButton();
        bg.add(dummy);

        int i = 0;
        for (ssTool b : tools){
            final ssTool c = b;
            b.getButton().addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    updateSelection(c);
                }
            });
            bg.add(b.getButton());
            add(b.getButton());
        }
    }

    public void updateSelection(ssTool t) {
        if (bg == null || bg.getSelection() == null) {
            return;
        }

        canvas.setTool(t);
        t.setCanvas(canvas);

        if (lastTool != null) {
            lastTool.deactivate();
        }
        t.window = window;
        t.activate();

        lastTool = t;
    }
}