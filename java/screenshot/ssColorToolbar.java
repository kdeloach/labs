import javax.swing.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class ssColorToolbar extends ssToolbar {
    final static int BTN_WIDTH = 20;
    final static int BTN_HEIGHT = 20;

    JToggleButton[] btns;
    ButtonGroup bg;

    Color[] Colors = new Color[] {
        Color.BLACK,
        Color.WHITE,
        Color.RED,
        Color.GREEN,
        Color.BLUE,
        Color.YELLOW
    };

    public ssColorToolbar() {
        super();

        bg = new ButtonGroup();
        JToggleButton tmp;

        int i = 0;
        for (Color c : Colors ) {
            tmp = createButton(c);
            tmp.setRolloverEnabled(true);
            tmp.setActionCommand(String.valueOf(i++));
            tmp.addMouseListener(new MouseAdapter() {
                public void mouseReleased(MouseEvent e) {
                    updateSelection();
                }
            });
            bg.add(tmp);
            add(tmp);
        }

        // Select the first element
        bg.getElements().nextElement().setSelected(true);
    }

    public JToggleButton createButton(Color c) {
        final Color j = c;

        return new JToggleButton() {
            public void paintComponent(Graphics g) {
                g.setColor(j);
                g.fillRect(0, 0, BTN_WIDTH, BTN_HEIGHT);
            }
            public void paintBorder(Graphics g) {
                super.paintBorder(g);
                if(isSelected()) {
                    g.setColor(getParent().getBackground());
                    g.fillRect(0, 0, BTN_WIDTH, 8);
                    g.setColor(Color.GRAY);
                    g.drawLine(0, 8, BTN_WIDTH, 8);
                }
            }
            public Dimension getPreferredSize() {
                return new Dimension(BTN_WIDTH, BTN_HEIGHT);
            }
        };
    }

    public void setCanvas(ssCanvas c) {
        super.setCanvas(c);
    }

    public void updateSelection() {
        canvas.color = Colors[Integer.valueOf(bg.getSelection().getActionCommand())];
        canvas.repaint();
    }
}