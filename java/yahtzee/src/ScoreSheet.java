import javax.swing.*;
import java.awt.*;

public class ScoreSheet extends JPanel
{
    private static final long serialVersionUID = 1L;

    public JTextField[] points = new JTextField[13];
    public JTextField subtotalTop, bonusTop, totalTop, subtotalBottom, bonusBottom, totalBottom, grandTotal;

    public ScoreSheet()
    {
        JPanel left,middle,right;

        for(int i = 0; i < points.length; i++)
        {
            points[i] = new JTextField(null, 4);
            points[i].setEditable(false);
        }

        subtotalTop = new JTextField("0", 4);
        subtotalTop.setEditable(false);
        bonusTop = new JTextField("0", 4);
        bonusTop.setEditable(false);
        totalTop = new JTextField("0", 4);
        totalTop.setEditable(false);
        subtotalBottom = new JTextField("0", 4);
        subtotalBottom.setEditable(false);
        bonusBottom = new JTextField("0", 4);
        bonusBottom.setEditable(false);
        totalBottom = new JTextField("0", 4);
        totalBottom.setEditable(false);
        grandTotal = new JTextField("0", 4);
        grandTotal.setEditable(false);

        left = new JPanel();
        left.setLayout(new GridBagLayout());
        GridBagConstraints c = new GridBagConstraints();
        c.insets = new Insets(2, 5, 2, 5);
        c.gridy = 0;

        c.gridy++;
        addComponents(new JLabel("Aces"), points[0], left, c);
        c.gridy++;
        addComponents(new JLabel("Twos"),points[1], left, c);
        c.gridy++;
        addComponents(new JLabel("Threes"),points[2], left, c);
        c.gridy++;
        addComponents(new JLabel("Fours"),points[3], left, c);
        c.gridy++;
        addComponents(new JLabel("Fives"),points[4], left, c);
        c.gridy++;
        addComponents(new JLabel("Sixes"),points[5], left, c);

        c.gridy++;
        addDivider(left, c);
        c.gridy++;
        addDivider(left, c);

        c.gridy++;
        addComponents(new JLabel("Subtotal"), subtotalTop, left, c);
        c.gridy++;
        addComponents(new JLabel("Bonus"), bonusTop, left, c);
        c.gridy++;
        addComponents(new JLabel("Total"), totalTop, left, c);

        middle = new JPanel();
        middle.setLayout(new GridBagLayout());
        c.gridy = 0;

        c.gridy++;
        addComponents(new JLabel("3 of a kind"), points[6], middle, c);
        c.gridy++;
        addComponents(new JLabel("4 of a kind"), points[7], middle, c);
        c.gridy++;
        addComponents(new JLabel("Full House"), points[8], middle, c);
        c.gridy++;
        addComponents(new JLabel("Small Straight"), points[9], middle, c);
        c.gridy++;
        addComponents(new JLabel("Large Straight"), points[10], middle, c);
        c.gridy++;
        addComponents(new JLabel("Chance"),points[11], middle, c);
        c.gridy++;
        addComponents(new JLabel("Yahtzee"),points[12], middle, c);

        c.gridy++;
        addDivider(middle, c);

        c.gridy++;
        addComponents(new JLabel("Subtotal"), subtotalBottom, middle, c);
        c.gridy++;
        addComponents(new JLabel("Bonus"), bonusBottom, middle, c);
        c.gridy++;
        addComponents(new JLabel("Total"), totalBottom, middle, c);

        ///////////////////////////////

        right = new JPanel();
        right.setLayout(new GridBagLayout());
        c.gridy = 0;

        addComponents(new JLabel("Grand Total"), grandTotal, right, c);

        /////////////////////////////

        setLayout(new GridBagLayout());
        c.fill = GridBagConstraints.BOTH;
        c.insets = new Insets(5, 5, 5, 5);
        c.ipadx = 0;

        c.gridx = 0;
        c.gridy = 0;
        c.anchor = GridBagConstraints.SOUTH;
        add(left,c);

        c.gridx = 1;
        c.gridy = 0;
        add(middle, c);

        c.gridx = 0;
        c.gridy = 1;
        c.gridwidth = 2;
        right.setBorder(BorderFactory.createLineBorder(Color.decode("#c0c0c0")));
        add(right, c);
    }
    private void addDivider(JPanel p, GridBagConstraints gbc)
    {
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.anchor = GridBagConstraints.WEST;
        gbc.ipadx = 10;
        p.add(new JLabel(" "), gbc);
        gbc.fill = GridBagConstraints.NONE;
        gbc.anchor = GridBagConstraints.EAST;
        gbc.ipadx = 0;
        p.add(new JLabel(" "), gbc);
    }
    // Source: http://forum.java.sun.com/thread.jspa?threadID=530292&messageID=2553400
    private void addComponents(Component c1, Component c2, JPanel p, GridBagConstraints gbc)
    {
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.anchor = GridBagConstraints.WEST;
        gbc.ipadx = 15;
        p.add(c1, gbc);
        gbc.fill = GridBagConstraints.NONE;
        gbc.anchor = GridBagConstraints.EAST;
        gbc.ipadx = 0;
        p.add(c2, gbc);
    }
    public void updateScore()
    {
        int total = 0;
        int subtotal = 0;

        for(int i = 0; i < 6; i++)
        {
            if(!points[i].getText().equals(new String()))
            {
                subtotal += new Integer(points[i].getText()).intValue();
            }
        }

        subtotalTop.setText(new Integer(subtotal).toString());
        total = subtotal;

        if(subtotal >= 63)
        {
            bonusTop.setText(new Integer(35).toString());
            total += 35;
            bonusTop.setText(new Integer(35).toString());
        }

        totalTop.setText(new Integer(total).toString());
        subtotal = 0;

        for(int i = 6; i < 13; i++)
        {
            if(!points[i].getText().equals(new String()))
            {
                subtotal += new Integer(points[i].getText()).intValue();
            }
        }

        subtotalBottom.setText(new Integer(subtotal).toString());
        int bonus = new Integer(bonusBottom.getText()).intValue();
        totalBottom.setText(new Integer(subtotal + bonus).toString());

        int total1 = new Integer(totalTop.getText()).intValue();
        int total2 = new Integer(totalBottom.getText()).intValue();

        grandTotal.setText(new Integer(total1 + total2).toString());
    }
    public void paint(Graphics g)
    {
        super.paint(g);
        paintChildren(g);
    }
}
