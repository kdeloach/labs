import javax.swing.JComponent;

import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Color;
import java.awt.Cursor;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import java.util.ArrayList;

class Dice extends JComponent implements MouseListener
{
	private static final long serialVersionUID = 1L;
	
	private Dimension size = new Dimension(36,36);
	
    public Dimension dot = new Dimension((int)(size.width/3),(int)(size.height/3));
    public Dimension arc = new Dimension((int)Math.sqrt(size.width),(int)Math.sqrt(size.height));
    //public Dimension arc = new Dimension((int)(size.width/4),(int)(size.height/4));
    
    private ArrayList<ActionListener> listeners = new ArrayList<ActionListener>();
    
    public int val;
    public int pos;
    
    private boolean mouseEntered = false;
    private boolean mousePressed = false;
    
    private DiceContainer container;
    
    public Dice(int pos,DiceContainer container)
    {
        this(null,pos,container);
    }
    public Dice(ActionListener e,int pos,DiceContainer container)
    {
        super();
     
        this.container = container;
        
        enableInputMethods(true);	
        addMouseListener(this);
        //addActionListener(e);
        
        setSize(size.width,size.height);
        setFocusable(true);
        
        this.pos = pos;
    }
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        if(val != -1)
        {
	        // turn on anti-alias mode
	        Graphics2D antiAlias = (Graphics2D)g;
	        antiAlias.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
	        
	        // draw white rectangle
	        g.setColor(Color.WHITE);
	        g.fillRoundRect(0,0,getWidth()-1,getHeight()-1,arc.width,arc.height);
	        
	        // draw black border
	        if(mouseEntered && val != -1)
	        	g.setColor(Color.YELLOW);
	        else
	        	g.setColor(Color.BLACK);
	        g.drawRoundRect(0,0,getWidth()-1,getHeight()-1,arc.width,arc.height);
	
	        // draw inside light border
	        g.setColor(Color.decode("#c0c0c0"));
	        g.drawRoundRect(1,1,getWidth()-3,getHeight()-3,arc.width,arc.height);
	        
	        int height;
			int width = height = dot.height*2/3;
	        
	        // possible positions for each dot on the dice        
	        // ~ x axis
	        int left   = getWidth()*1/3-dot.width/2-width/4;
	        int center = getWidth()*2/3-dot.width/2-width/2;
	        int right  = getWidth()*3/3-dot.width/2-width*3/4;
	                    
	        // ~ y axis
	        int top    = getHeight()*1/3-dot.height/2-height/4;
	        int middle = getHeight()*2/3-dot.height/2-height/2;
	        int bottom = getHeight()*3/3-dot.height/2-height*3/4;
	
	 		// draw grid
	        g.setColor(Color.RED);
	        for(int x = 0; x < 3; x++)
		        for(int y = 0; y < 3; y++)
		        	;//g.drawRect(x*getWidth()/3,y*getHeight()/3,getWidth()/3,getHeight()/3);        	
	        
        	// draw the dots
        	g.setColor(Color.BLACK);
	        switch(val)
	        {
		        case 0:
		        	break;
				case 1:
				    g.fillOval(center,middle,width,height);
				    break;
				case 2:
				    g.fillOval(right,top,width,height);
				    g.fillOval(left,bottom,width,height);
				    break;
				case 3:
				    g.fillOval(right,top,width,height);
				    g.fillOval(center,middle,width,height);
				    g.fillOval(left,bottom,width,height);
				    break;
				case 4:
				    g.fillOval(left,top,width,height);
				    g.fillOval(left,bottom,width,height);
				    g.fillOval(right,top,width,height);
				    g.fillOval(right,bottom,width,height);
				    break;
				case 5:
				    g.fillOval(left,top,width,height);
				    g.fillOval(left,bottom,width,height);
				    g.fillOval(right,top,width,height);
				    g.fillOval(right,bottom,width,height);
				    g.fillOval(center,middle,width,height);
				    break;
				case 6:
				    g.fillOval(left,top,width,height);
				    g.fillOval(left,middle,width,height);
				    g.fillOval(left,bottom,width,height);
				    g.fillOval(right,top,width,height);
				    g.fillOval(right,middle,width,height);
				    g.fillOval(right,bottom,width,height);
				    break;
	        }
        }
    }
    public void roll()
    {
        // the amount of sides on the dice
        int faces = 6;
        
        // give this dice a random number  from 1-6
        val = (int)(Math.random()*faces+1);
    }
    public void mouseClicked(MouseEvent e)
    {
    }
    public void mouseEntered(MouseEvent e)
    {
        mouseEntered = true;
        
        if(val != -1)
        	setCursor(new Cursor(Cursor.HAND_CURSOR));
        
        repaint();
    }
    public void mouseExited(MouseEvent e)
    {
        mouseEntered = false;
        
        setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
        
        repaint();
    }
    public void mousePressed(MouseEvent e)
    {        
        notifyListeners(e);
        
        mousePressed = true;
        
        repaint();
    }
    public void mouseReleased(MouseEvent e)
    {
        mousePressed = false;
        
        if(val != 0)
        {
	        container.depot.addDice(val);
	        container.depot.repaint();
	        
	        container.removeDice(pos);
	        container.repaint();
	        
	        setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
    	}
        
        repaint();
    }
    public void addActionListener(ActionListener listener)
    {
        listeners.add(listener);
    }
    private void notifyListeners(MouseEvent e)
    {
        ActionEvent evt = new ActionEvent(this,ActionEvent.ACTION_PERFORMED,new String(),e.getWhen(),e.getModifiers());
        
        synchronized(listeners)
        {
            for (int i = 0; i < listeners.size(); i++)
            {
                ActionListener tmp = listeners.get(i);
            	tmp.actionPerformed(evt);
            }
        }
    }
    public Dimension getPreferredSize()
    {
        return new Dimension(getWidth(),getHeight());
    }
    public Dimension getMinimumSize()
    {
        return getPreferredSize();
    }
    public Dimension getMaximumSize()
    {
        return getPreferredSize();
    }
}