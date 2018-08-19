import javax.swing.*;
import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.util.*;

public class Screenshot {
    ssWindow window;
    ssToolsToolbar tools;
    ssColorToolbar colors;
    JButton submitButton;
    ssCanvas canvas;

    // Scale of the screenshot
    double scale = 0.80;

    public static void main(String[] argv) {
        new Screenshot();
    }

    public Screenshot(){
        createWindow();
        createCanvas();
        createToolsToolbar();
        createColorsToolbar();
        createSubmitButton();

        tools.setCanvas(canvas);
        colors.setCanvas(canvas);

        // Select the default tool
        tools.tools[0].getButton().doClick();

        addComponentsToWindow();

        // take the screenshot
        takeSnapshot();

        showWindow();
    }

    public void createWindow() {
        window = new ssWindow("Screenshot");

        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setLayout(new FlowLayout());

        window.setResizable(false);
        window.setAlwaysOnTop(false);
    }

    public void createToolsToolbar() {
        tools = new ssToolsToolbar(window);
    }

    public void createColorsToolbar() {
        colors = new ssColorToolbar();
    }

    public void createSubmitButton() {
    }

    public void createCanvas() {
        canvas = new ssCanvas();
    }

    public void addComponentsToWindow() {
        window.setLayout(new BorderLayout());

        JToolBar toolbar = new JToolBar();
        toolbar.setLayout(new FlowLayout());
        toolbar.setFloatable(false);
        toolbar.setRollover(true);
        toolbar.add(tools);
        toolbar.addSeparator();
        toolbar.add(colors);
        toolbar.addSeparator();
        toolbar.add(new JButton("Send Screenshot"));

        window.add(toolbar, BorderLayout.PAGE_START);
        window.add(canvas, BorderLayout.CENTER);
    }

    public void takeSnapshot() {
        Toolkit toolkit = Toolkit.getDefaultToolkit();
        Dimension screenSize = toolkit.getScreenSize();
        Rectangle screenRect = new Rectangle(screenSize);
        try {
            Robot robot = new Robot();
            BufferedImage image = robot.createScreenCapture(screenRect);
            image = scale(image, scale);
            canvas.setBackground(image);
        } catch (Exception ie) {
            System.out.println("Error");
        }
    }

    private BufferedImage scale(BufferedImage bi, double scale) {
        AffineTransform tx = new AffineTransform();
        tx.scale(scale, scale);
        AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_BICUBIC);
        return op.filter(bi, null);
    }

    public void showWindow() {
        window.pack();
        window.setVisible(true);
    }
}