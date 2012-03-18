import javax.swing.JPanel;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;

import java.util.Arrays;
import java.util.ArrayList;

public class DiceContainer extends JPanel
{
    private static final long serialVersionUID = 1L;

    private final int SMALL_STRAIGHT = 4;
    private final int LARGE_STRAIGHT = 5;

    public Dice[] dice = new Dice[5];
    public Dice[] total = new Dice[5];
    public DiceContainer depot;
    public ScoreSheet scorecard;

    public DiceContainer(Dice[] d)
    {
        this.dice = d;

        for(int i = 0; i < dice.length; i++)
        {
            dice[i] = new Dice(i, this);
            dice[i].val = -1;

            total[i] = new Dice(i, null);
            total[i].val = -1;

            add(dice[i]);
        }

        repaint();
    }
    public void paint(Graphics g)
    {
        super.paint(g);

        // turn on anti-alias mode
        Graphics2D antiAlias = (Graphics2D)g;
        antiAlias.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        int arc = 15;
        int offset = 1;

        g.setColor(Color.decode("#555555"));
        g.fillRoundRect(0, 0, getWidth(), getHeight(), arc, arc);

        g.setColor(Color.decode("#cccccc"));
        g.fillRoundRect(offset, offset, getWidth() - (offset * 2), getHeight() - (offset * 2), arc, arc);

        g.setColor(Color.WHITE);
        for(int i = 0; i < dice.length; i++)
        {
            g.fillRoundRect(
                dice[i].getX() - offset,
                dice[i].getY() - offset,
                dice[i].getWidth() + (offset * 2),
                dice[i].getHeight() + (offset * 2),
                dice[i].arc.width,
                dice[i].arc.height
            );
        }

        super.paintChildren(g);
    }
    public void addDice()
    {
        for(int i = 0; i < dice.length; i++)
        {
            if(dice[i].val == -1)
            {
                dice[i].val = 0;
                return;
            }
        }
        return;
    }
    public boolean addDice(int val)
    {
        for(int i = 0; i < dice.length; i++)
        {
            if(dice[i].val == -1)
            {
                dice[i].val = val;
                return true;
            }
        }
        return false;
    }
    // Return true if that category has already been filled (Aces, Twos, etc.)
    private boolean alreadyUsed(int cat)
    {
        return (!scorecard.points[cat].getText().equals(""));
    }
    public void makeTotal(Dice[] bottom)
    {
        ArrayList<Dice> tmp = new ArrayList<Dice>(5);

        for(int i = 0; i < total.length; i++)
        {
            if(dice[i].val != -1)
            {
                tmp.add(dice[i]);
            }
            if(bottom[i].val != -1)
            {
                tmp.add(bottom[i]);
            }
        }

        Object[] tmp2 = tmp.toArray();
        for(int i = 0; i < tmp2.length; i++)
        {
            total[i] = (Dice)tmp2[i];
        }
    }
    public void removeDice(int pos)
    {
        if(dice[pos].val != -1)
        {
            dice[pos].val = -1;
        }
    }
    public void roll()
    {
        for(int i = 0; i < dice.length; i++)
        {
            if(dice[i].val != -1)
            {
                dice[i].roll();
            }
        }
    }
    private int occurenceOf(int val)
    {
        int result = 0;
        for(int i = 0; i < total.length; i++)
        {
            if(total[i].val == val)
            {
                result++;
            }
        }
        return result;
    }
    private int diceTotal()
    {
        int result = 0;
        for(int i = 0; i < total.length; i++)
        {
            if(total[i].val > 0)
            {
                result += total[i].val;
            }
        }
        return result;
    }
    private boolean isStraight(int pos, int[] vals, int spread)
    {
        if(spread == 0)
            return true;
        else if(pos >= vals.length)
            return false;
        else if(vals[pos] == 0)
            return isStraight(pos + 1, vals, spread);
        else if(pos + 1 >= vals.length || vals[pos] + 1 == vals[pos + 1])
            return isStraight(pos + 1, vals, spread - 1);
        return false;
    }
    public Object[] options()
    {
        ArrayList<Sortie> options = new ArrayList<Sortie>(13);

        int[] points = new int[13];
        for(int i = 0; i < points.length; i++)
        {
            points[i] = 0;
        }

        int[] vals = new int[total.length];
        for(int i = 0; i < vals.length; i++)
        {
            vals[i] = total[i].val;
        }

        // One's, Two's, etc.
        points[0] = occurenceOf(1);
        points[1] = occurenceOf(2) * 2;
        points[2] = occurenceOf(3) * 3;
        points[3] = occurenceOf(4) * 4;
        points[4] = occurenceOf(5) * 5;
        points[5] = occurenceOf(6) * 6;

        // 3 of a kind
        for(int i = 0; i < dice.length; i++)
        {
            if(total[i].val != -1 && occurenceOf(total[i].val) >= 3)
            {
                points[6] = diceTotal();
                break;
            }
        }

        // 4 of a kind
        for(int i = 0; i < total.length; i++)
        {
            if(total[i].val != -1 && occurenceOf(total[i].val) >= 4)
            {
                points[7] = diceTotal();
                break;
            }
        }

        // Full House
        boolean two = false;
        boolean three  = false;
        for(int i = 0; i < total.length; i++)
        {
            if(occurenceOf(total[i].val) == 2)
            {
                two = true;
            }
            else if(occurenceOf(total[i].val) == 3)
            {
                three = true;
            }
        }
        if(two && three)
        {
            points[8] = 25;
        }

        // Small Straight
        int[] tmp = vals;
        // set duplicates to 0
        for(int l = 0; l < tmp.length; l++)
        {
            for(int r = tmp.length-1; r > l; r--)
            {
                if(tmp[l] == tmp[r])
                {
                    tmp[r] = 0;
                }
            }
        }
        Arrays.sort(tmp);
        if(isStraight(0, tmp, SMALL_STRAIGHT))
        {
            points[9] = 30;
        }

        // Large Straight
        tmp = vals;
        // set duplicates to 0
        for(int l = 0; l < tmp.length; l++)
        {
            for(int r = tmp.length-1; r > l; r--)
            {
                if(tmp[l] == tmp[r])
                {
                    tmp[r] = 0;
                }
            }
        }
        Arrays.sort(tmp);
        if(isStraight(0, tmp, LARGE_STRAIGHT))
        {
            points[10] = 40;
        }

        // Chance
        points[11] = diceTotal();

        // Yahtzee
        int valTotal = 0;
        for(int i = 0; i < vals.length; i++)
        {
            valTotal += vals[i];
        }
        if(occurenceOf(valTotal) == 5)
        {
            if(!alreadyUsed(12))
            {
                points[12] = 50;
            }
            else if(new Integer(scorecard.bonusBottom.getText()).intValue() < 300)
            {
                points[12] = 100;
            }
            else
            {
                points[12] = 0;
            }
        }

        if(!alreadyUsed(0) && points[0] > 0) options.add(new Sortie("Ones", points[0], 0));
        if(!alreadyUsed(1) && points[1] > 0) options.add(new Sortie("Twos", points[1], 1));
        if(!alreadyUsed(2) && points[2] > 0) options.add(new Sortie("Threes", points[2], 2));
        if(!alreadyUsed(3) && points[3] > 0) options.add(new Sortie("Fours", points[3], 3));
        if(!alreadyUsed(4) && points[4] > 0) options.add(new Sortie("Fives", points[4], 4));
        if(!alreadyUsed(5) && points[5] > 0) options.add(new Sortie("Sixes", points[5], 5));
        if(!alreadyUsed(6) && points[6] > 0) options.add(new Sortie("3 of a kind", points[6], 6));
        if(!alreadyUsed(7) && points[7] > 0) options.add(new Sortie("4 of a kind", points[7], 7));
        if(!alreadyUsed(8) && points[8] > 0) options.add(new Sortie("Full House", points[8], 8));
        if(!alreadyUsed(9) && points[9] > 0) options.add(new Sortie("Small Straight", points[9], 9));
        if(!alreadyUsed(10) && points[10] > 0) options.add(new Sortie("Large Straight", points[10], 10));
        if(!alreadyUsed(11) && points[11] > 0) options.add(new Sortie("Chance", points[11], 11));
        if(points[12] > 0) options.add(new Sortie("Yahtzee", points[12], 12));

        return options.toArray();
    }
}
