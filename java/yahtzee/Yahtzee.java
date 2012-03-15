import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

class Yahtzee extends JPanel implements ActionListener
{
	private static final long serialVersionUID = 1L;

	DiceContainer diceContainer,depot;
	
	public static Point pos;
	
	final String ROLL = "Roll",SELECT = "Select";
	
	JButton rollButton,selectButton;
	JComboBox<Object> choices;
	
	Dice[] top = new Dice[5];
	Dice[] bottom = new Dice[5];
	
	public static ScoreSheet scorecard;
	
	int rolls = 0;
	int turns = 0;
	
	public Yahtzee()
	{			
		/////////////////////////////////////////
		// DICE
		diceContainer = new DiceContainer(top);
		for(int i = 0; i < 5; i++)
			diceContainer.addDice();
		
		depot = new DiceContainer(bottom);
		
		diceContainer.depot = depot;
		depot.depot = diceContainer;
		/////////////////////////////////////////
		
		// ROLL button
		rollButton = new JButton(ROLL);
		rollButton.addActionListener(this);
			
		// Scoring Choices
		choices = new JComboBox<Object>();
		choices.setMaximumRowCount(13);
		
		// SELECT button
		selectButton = new JButton(SELECT);
		selectButton.addActionListener(this);
		
		// ------------------
		
		// Put it all together...
	
		int padding = 5;
		
		setLayout(new GridBagLayout());
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.BOTH;
		c.insets = new Insets(padding,padding,padding,padding);
		
		c.gridx = 0;
		c.gridy = 0;
		add(diceContainer, c);
		
		c.gridx = 0;
		c.gridy = 1;
		add(depot, c);
		
		c.gridx = 1;
		c.gridy = 0;
		c.gridheight = 2;
		add(rollButton, c);
		
		c.gridx = 0;
		c.gridy = 2;
		add(choices, c);
		
		c.gridx = 1;
		c.gridy = 2;
		add(selectButton, c);
	}
	public void actionPerformed(ActionEvent e)
	{
		if(turns >= 13)
			return;
			
		if(e.getActionCommand().equals(ROLL))
		{
			if(rolls < 3)
			{
				diceContainer.roll();
				
				rolls++;
				
				updateOptions();
				
				repaint();
			}
		}
		else if(e.getActionCommand().equals(SELECT) && choices.getSelectedItem() != null)
		{
			int score = new Integer(((Sortie)choices.getSelectedItem()).val).intValue();
			int ID = new Integer(((Sortie)choices.getSelectedItem()).ID).intValue();
			String caption = (String)((Sortie)choices.getSelectedItem()).caption;
			
			if(caption.equals("Yahtzee"))
			{
				if(scorecard.points[ID].getText().equals(new String()))
					scorecard.points[ID].setText(new Integer(score).toString());
				else
				{
					int bonus = 0;
					
					if(!scorecard.bonusBottom.getText().equals(new String()))
						bonus = new Integer(scorecard.bonusBottom.getText()).intValue();
					
					scorecard.bonusBottom.setText(new Integer(bonus+score).toString());
					
					turns--;
				}
			}
			else if(scorecard.points[ID].getText().equals(new String()))
				scorecard.points[ID].setText(new Integer(score).toString());

			scorecard.updateScore();
			
			for(int i = 0; i < 5; i++)
			{
				diceContainer.removeDice(i);
				diceContainer.addDice();
				
				depot.removeDice(i);
			}
			
			rolls = 0;	
			turns++;
			
			updateOptions();
			
			repaint();
		}
	}
	public void updateOptions()
	{
		diceContainer.scorecard = scorecard;
		diceContainer.makeTotal(bottom);
		
		DefaultComboBoxModel<Object> newModel;
		
		if(rolls == 0)
			newModel = new DefaultComboBoxModel<Object>(new String[]{});
		else
			newModel = new DefaultComboBoxModel<Object>(diceContainer.options());
		
		choices.setModel(newModel);
	}
	public static JMenuBar createJMenuBar()
	{
		JMenuBar menuBar = new JMenuBar();
		JMenu menu;
		JMenuItem menuItem;
		
		menu = new JMenu("Game"); menu.setMnemonic(KeyEvent.VK_G);
		menuItem = new JMenuItem("New Game"); menu.add(menuItem);  menuItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_N,ActionEvent.CTRL_MASK));
		menu.addSeparator();
		menuItem = new JMenuItem("Exit"); menu.add(menuItem);  menuItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_F4,ActionEvent.ALT_MASK));
		menuBar.add(menu);
		
		menu = new JMenu("Edit"); menu.setMnemonic(KeyEvent.VK_E);
		menuItem = new JMenuItem("Undo"); menuItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_Z,ActionEvent.CTRL_MASK)); menu.add(menuItem);
		menuItem = new JMenuItem("Redo"); menuItem.setAccelerator(KeyStroke.getKeyStroke(KeyEvent.VK_Y,ActionEvent.CTRL_MASK)); menuItem.setMnemonic(KeyEvent.VK_Y); menu.add(menuItem);
		menuBar.add(menu);
		
		menu = new JMenu("View"); menu.setMnemonic(KeyEvent.VK_V);
		menuItem = new JMenuItem("Score Sheet"); menu.add(menuItem);
		menuBar.add(menu);
		
		menu = new JMenu("Help"); menu.setMnemonic(KeyEvent.VK_H);
		menuItem = new JMenuItem("How To Play"); menu.add(menuItem);
		menuItem = new JMenuItem("Rules"); menu.add(menuItem);
		menu.addSeparator();
		menuItem = new JMenuItem("About"); menu.add(menuItem);
		menuBar.add(menu);
		
		return menuBar;
	}
	
	public static void main(String[] argv)
	{
		JFrame left = new JFrame();
		
		JPanel game = new Yahtzee();
		
		left.getContentPane().setLayout(new GridBagLayout());
		left.getContentPane().add(game);
		left.setJMenuBar(createJMenuBar());
		left.pack();
		
		left.setResizable(false);
		left.setTitle("crimson_cubes");
		left.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		///////////////////
		JFrame right = new JFrame();
		
		scorecard = new ScoreSheet();
		
		right.getContentPane().setLayout(new GridBagLayout());
		right.getContentPane().add(scorecard);
		right.pack();
		
		right.setResizable(false);
		right.setTitle("crimson_cubes scoresheet");
		right.setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
		///////////////////
		
		Dimension res = Toolkit.getDefaultToolkit().getScreenSize();
		pos = new Point(res.width/2-left.getWidth()/2-right.getWidth()/2,res.height/2-right.getHeight()/2);
		
		///////////////////////
		
		left.setLocation(pos.x,pos.y);
		left.setVisible(true);
		
		right.setLocation(left.getX()+left.getWidth(),left.getY());
		right.setVisible(true);
	}
}