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

	private final int ALL_DICE = -6;

	public Dice[] dice = new Dice[5],total = new Dice[5];
	public DiceContainer depot;
	public ScoreSheet scorecard;
	
	public DiceContainer(Dice[] d)
	{				
		this.dice = d;
		
		for(int i = 0; i < dice.length; i++)
		{
			dice[i] = new Dice(i,this);
			dice[i].val = -1;
			
			total[i] = new Dice(i,null);
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
        antiAlias.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
		
        int arc = 15;
        
		g.setColor(Color.decode("#555555"));
		g.fillRoundRect(0,0,getWidth(),getHeight(),arc,arc);
		
		int offset = 1;
		
		g.setColor(Color.decode("#cccccc"));
		g.fillRoundRect(offset,offset,getWidth()-(offset*2),getHeight()-(offset*2),arc,arc);
		
		g.setColor(Color.WHITE);
		for(int i = 0; i < dice.length; i++)
			g.fillRoundRect(dice[i].getX()-offset,dice[i].getY()-offset,dice[i].getWidth()+(offset*2),dice[i].getHeight()+(offset*2),dice[i].arc.width,dice[i].arc.height);
		
		super.paintChildren(g);
	}
	
	public void addDice()
	{
		for(int i = 0; i < dice.length; i++)
		{
			if(dice[i].val == -1)
			{
				//dice[i].roll();
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
	// true if that category has already been filled (Aces,Twos,etc)
	private boolean alreadyUsed(int cat)
	{
		return (!scorecard.points[cat].getText().equals(new String()));
	}
	public void makeTotal(Dice[] bottom)
	{
		ArrayList<Dice> tmp = new ArrayList<Dice>(5);

		for(int i = 0; i < total.length; i++)
		{
			if(dice[i].val != -1)
				tmp.add(dice[i]);
			if(bottom[i].val != -1)
				tmp.add(bottom[i]);
				
			//System.out.print(tmp.get(i).val+" ");
		}
		
		//System.out.println();
		
		Object[] tmp2 = tmp.toArray();
		
		for(int i = 0; i < tmp2.length; i++)
			total[i] = (Dice)tmp2[i];
	}
	public void removeDice(int pos)
	{
		if(dice[pos].val != -1)
			dice[pos].val = -1;
	}
	
	public void roll()
	{
		for(int i = 0; i < dice.length; i++)
			if(dice[i].val != -1)
				dice[i].roll();
	}
	private int occurenceOf(int val)
	{
		int occurence = 0;
		
		for(int i = 0; i < total.length; i++)
			if(total[i].val == val)
				occurence++;
		
		return occurence;
	}
	private int totalOf(int val)
	{
		if(val < 0)
			// NOTE:   totalOf(-6)
			//       = totalOf( 6)+totalOf(-5)
			//       =             totalOf( 5)+totalOf(-4)
			// and so forth...
			return totalOf(val*-1)+totalOf(val+1);
		else
			return occurenceOf(val)*val;
	}
	
	private final int SMALL_STRAIGHT = 4;
	private final int LARGE_STRAIGHT = 5;	
	
	private boolean isStraight(int pos, int[] vals, int spread)
	{
		if(spread ==0)
			return true;
		else if(pos >= vals.length)
			return false;
		else if(vals[pos] == 0)
			return isStraight(pos+1, vals, spread);
		else if(pos+1 >= vals.length || vals[pos]+1 == vals[pos+1])
			return isStraight(pos+1, vals, spread-1);
			
		return false;
	}
	public Object[] options()
	{
		int[] points = new int[13];
				
		for(int i = 0; i < points.length; i++)
			points[i] = 0;
		
		ArrayList<Sortie> options = new ArrayList<Sortie>(13);
		
		int[] vals = new int[total.length];
			
		for(int i = 0; i < vals.length; i++)
			vals[i] = total[i].val;
		
		// add total for dice value i (One's, Two's, etc.)
		{
			for(int i = 1; i <= 6; i++)
				points[i-1] = totalOf(i);
		}
	
		// check for 3 of a kind
		{
			for(int i = 0; i < dice.length; i++)
				if(total[i].val != -1 && occurenceOf(total[i].val) >= 3)
				{
					points[6] = totalOf(ALL_DICE);
					
					break;
				}
		}
		
		// check for 4 of a kind
		{
			for(int i = 0; i < total.length; i++)
				if(total[i].val != -1 && occurenceOf(total[i].val) >= 4)
				{
					points[7] = totalOf(ALL_DICE);
					
					break;
				}
		}
		
		// check for Full House
		{
			boolean two = false, three  = false;
			
			for(int i = 0; i < total.length; i++)
				if(occurenceOf(total[i].val) == 2)
					two = true;
				else if(occurenceOf(total[i].val) == 3)
					three = true;
			
			if(three && two)
				points[8] = 25;
		}
		
		// check for Small Straight
		{
			int[] tmp = vals;
			
			// set duplicates to 0
			for(int l = 0; l < tmp.length; l++)
				for(int r = tmp.length-1; r > l; r--)
					if(tmp[l] == tmp[r])
						tmp[r] = 0;
			
			// sort
			Arrays.sort(tmp);
			
			if(isStraight(0, tmp, SMALL_STRAIGHT))
				points[9] = 30;
		}
		
		// check for Large Straight
		{
			int[] tmp = vals;
			
			// set duplicates to 0
			for(int l = 0; l < tmp.length; l++)
				for(int r = tmp.length-1; r > l; r--)
					if(tmp[l] == tmp[r])
						tmp[r] = 0;
			
			// sort
			Arrays.sort(tmp);
			
			if(isStraight(0, tmp, LARGE_STRAIGHT))
				points[10] = 40;
		}
		
		// add Chance
		{
			points[11] = totalOf(ALL_DICE);
		}
		
		// check for Yahtzee
		{
			for(int i = 1; i <= 6; i++)
				if(occurenceOf(i) == 5)
				{
					if(!alreadyUsed(12))
						points[12] = 50;
					else if(new Integer(scorecard.bonusBottom.getText()).intValue() < 300)
						points[12] = 100;
					else
						points[12] = 0;
				
					break;	
				}
		}
		
		if(!alreadyUsed(0))  options.add(new Sortie("Ones",			  points[0],0));
		if(!alreadyUsed(1))  options.add(new Sortie("Twos",			  points[1],1));
		if(!alreadyUsed(2))  options.add(new Sortie("Threes",		  points[2],2));
		if(!alreadyUsed(3))  options.add(new Sortie("Fours",		  points[3],3));
		if(!alreadyUsed(4))  options.add(new Sortie("Fives",		  points[4],4));
		if(!alreadyUsed(5))  options.add(new Sortie("Sixes",		  points[5],5));
		if(!alreadyUsed(6))  options.add(new Sortie("3 of a kind",	  points[6],6));
		if(!alreadyUsed(7))  options.add(new Sortie("4 of a kind",	  points[7],7));
		if(!alreadyUsed(8))  options.add(new Sortie("Full House",	  points[8],8));
		if(!alreadyUsed(9))  options.add(new Sortie("Small Straight", points[9],9));
		if(!alreadyUsed(10)) options.add(new Sortie("Large Straight", points[10],10));
		if(!alreadyUsed(11)) options.add(new Sortie("Chance",		  points[11],11));
		
		if(!alreadyUsed(12) || points[12] > 0) options.add(new Sortie("Yahtzee",points[12],12));
		
		/*
		// remove any empty sorties
		for(int l = 0; l < options.size(); l++)
			for(int r = options.size()-1; r >= l; r--)
				if(((Sortie)options.get(l)).val == 0)
					options.remove(l);

		// sort the Sorties, smallest to highest
		for(int l = 0; l < options.size(); l++)
			for(int r = options.size()-1; r >= l; r--)
				if(((Sortie)options.get(l)).val > ((Sortie)options.get(r)).val)
				{
					Sortie tmp = (Sortie)options.get(r);
					
					options.set(r, options.get(l));
					options.set(l, tmp);
				}
		*/
		
		return options.toArray();
	}
}