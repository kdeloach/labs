import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyListener;

import javax.swing.BoxLayout;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;


public class Execute
{
    JFrame frame;
    Deflexion bt;

    public static void main(String argv[])
    {
        new Execute();
    }
    
    public Execute()
    {
        frame = new JFrame("Deflexion");

        Status sts = new Status();
        sts.setAlignmentX(Component.CENTER_ALIGNMENT);

        bt = new Deflexion(sts);
        frame.addKeyListener((KeyListener)bt);

        Container pane = frame.getContentPane();
        pane.setBackground(Color.WHITE);
        pane.setLayout(new BoxLayout(pane, BoxLayout.Y_AXIS));
        pane.add(bt);
        pane.add(sts);

        JMenuBar bar = new JMenuBar();
        JMenu men = new JMenu("File");
        JMenuItem item = new JMenuItem("Exit");
        item.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    System.exit(1);
                }
            }
        );
        men.add(item);
        bar.add(men);

        frame.setJMenuBar(bar);
        
        frame.setResizable(false);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        frame.pack();

        Toolkit kit = Toolkit.getDefaultToolkit();
        Dimension size = kit.getScreenSize();
        frame.setLocation(size.width/2 - frame.getWidth()/2, size.height/2 - frame.getHeight()/2);

        frame.setVisible(true);
    }
}
