
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class Main extends JApplet {

	private static final long serialVersionUID = 1L;
	
	// How many cards in the deck, e.g. 1-42
	final static int AMT_CARDS = 42;
	
	// How many cards in each tower
	final static int CARDS_PER_TOWER = 10;
	
	// Holds all the cards- or "blocks" -towers can use
	Stack<Integer> deck;
	
	// Towers 
	ArrayList<Integer> tower, enemy;
	
	// Shows current card for this round
	Integer currentCard;
	
	boolean gameover = false;
		
	/* * * * * * * * * * * */
	// Interface Components
	
	// Panels
	JPanel towerPanel, enemyPanel;
	JPanel cardSelectionPanel;
	
	// Currently selected card
	JLabel currentCardLabel;
	// Button to draw a new card
	JButton newCardBtn;
	
	// Horizontal padding between blocks in a tower
	final int towerHorizontalPadding = 4;
	
	/* * * * * * * * * * * */
	
	public static void main(String[] argv)
	{
		
	}
	
	public void init(){		
		// Initialize Deck
		deck = new Stack<Integer>();
		for(int i=0;i<AMT_CARDS;i++)
			deck.add(i+1);
		// Shuffle deck
		Collections.shuffle(deck);
		
		// Initialize Tower1, and enemy
		tower = new ArrayList<Integer>(CARDS_PER_TOWER);
		enemy = new ArrayList<Integer>(CARDS_PER_TOWER);
		for(int i=0; i < CARDS_PER_TOWER ;i++){
			// Populate tower, draw cards from top of deck
			tower.add( deck.pop() );
			enemy.add( deck.pop() );
		}
		
		// Set the default selected card
		currentCard = deck.pop();
		
		// Draw UI
		renderUI();
		
		/*while( !solved(tower) ){
			currentCard = deck.pop();
			
			System.out.println(currentCard);
			
			//break;
			
			// Update UI
			//updateUI();
		}*/
	}
	
	// Returns true if tower is sorted lowest to highest
	public boolean solved(ArrayList<Integer> tower){
		Integer n=0;
		for(Integer v : tower){
			// Value is less than previous value, list isn't sorted 
			if(v < n)
				return false;
			n = v;
		} 
		return true;
	}
	
	public void drawCard(){
		deck.add( deck.size(), currentCard );
		// For some reason, deck.pop() won't work here
		currentCard = deck.remove(0);
		
		updateUI();
	}
	
	// Construct UI 
	// This should be called only once, when the program starts
	@SuppressWarnings("serial")
	public void renderUI(){
		// Applet Background Color - gmail blue
		setBackground(new Color(0xE0, 0xEC, 0xFF));
		setSize(400,375);

		/** Card selection panel **/
		cardSelectionPanel = new JPanel();
		cardSelectionPanel.setLayout( new BoxLayout( cardSelectionPanel, BoxLayout.Y_AXIS ) );
		cardSelectionPanel.setAlignmentX(JPanel.CENTER_ALIGNMENT);
		
		currentCardLabel = new CardLabel( currentCard.toString() ){
			public Dimension getPreferredSize(){
				return new Dimension(50,50);
			}
		};
		currentCardLabel.setFont( new Font("Dialog", Font.PLAIN, 32) ); 
		currentCardLabel.setCursor( Cursor.getDefaultCursor() );
		// Create "draw card" button and action
		newCardBtn = new JButton("Draw Card");
		newCardBtn.setAlignmentX(JPanel.CENTER_ALIGNMENT);
		newCardBtn.addActionListener( new ActionListener(){
			public void actionPerformed(ActionEvent e){
				drawCard();
			}
		});
		/*JButton b = new JButton("New Game");
		b.addActionListener( new ActionListener(){
			public void actionPerformed(ActionEvent e){
				newGame();
			}
		});*/
		cardSelectionPanel.add( currentCardLabel );
		cardSelectionPanel.add( Box.createVerticalStrut(15));
		cardSelectionPanel.add( newCardBtn );
		//cardSelectionPanel.add( b );
		
		
		/** Tower Panels **/
		// Make this panel interactive
		towerPanel = new TowerJPanel(this){
			public void mouseClicked(MouseEvent e){
				doPlayerTurn();
			}
		};
		towerPanel.addMouseListener((MouseListener)towerPanel);
		towerPanel.addMouseMotionListener((MouseMotionListener)towerPanel);
		towerPanel.setLayout(new BoxLayout(towerPanel, BoxLayout.Y_AXIS));
		
		enemyPanel = new TowerJPanel(this);
		enemyPanel.setLayout(new BoxLayout(enemyPanel, BoxLayout.Y_AXIS));
		
		// Add a label for each value in tower
		//for(Integer n : tower){
		for(int i=0,l=tower.size(); i < l; i++){
			towerPanel.add( Box.createVerticalStrut( (int)(towerHorizontalPadding/2) ) );
			towerPanel.add( new CardLabel( tower.get(i).toString() ) );
			towerPanel.add( Box.createVerticalStrut( (int)(towerHorizontalPadding/2) ) );
			
			enemyPanel.add( Box.createVerticalStrut( (int)(towerHorizontalPadding/2) ) );
			CardLabel c = new CardLabel( enemy.get(i).toString() );
			// Get rid of that hand cursor
			c.setCursor( Cursor.getDefaultCursor() );
			enemyPanel.add( c );
			enemyPanel.add( Box.createVerticalStrut( (int)(towerHorizontalPadding/2) ) );
		}
		
		
		/** Add components **/
		setLayout( new GridBagLayout() );
		GridBagConstraints c = new GridBagConstraints();
		c.insets = new Insets(5, 5, 5, 5);
		c.weighty=1;
		c.weightx=1;
		
		c.gridx=0;
		c.gridy=0;
		c.gridheight=3;
		c.gridwidth=1;
		add(enemyPanel, c);
		
		c.gridx=1;
		c.gridy=1;
		c.gridheight=1;
		c.gridwidth=1;
		add(cardSelectionPanel, c);
		
		c.gridx=2;
		c.gridy=0;
		c.gridheight=3;
		c.gridwidth=1;
		add(towerPanel, c);
	}
		
	public void updateUI(){
		// Update Labls in Tower Panel
		for(int i=0,len=tower.size(); i < len; i++){
			// Get component i*3+1 in panel, added some offsets do to padding 
			// Each label component has a Filler component above and below
			// so the layout looks like this: filler, label, filler, filler, label, filler, filler, label, etc.
			JLabel l = (JLabel)towerPanel.getComponent( i*3+1 );
			l.setText( tower.get(i).toString() );
			
			// Update enemy panel as well
			((JLabel)enemyPanel.getComponent( i*3+1 )).setText( enemy.get(i).toString() );
		}
		towerPanel.validate();
		enemyPanel.validate();
		
		// Update selected card
		currentCardLabel.setText( currentCard.toString() );
	}
	
	// Resets game variables
	public void newGame(){
		gameover = false;
		
		// Return all the cards to the deck
		for(Integer n : tower)
			deck.push( n );
		deck.push(currentCard);
		
		Collections.shuffle(deck);
		
		for(int i=0; i < CARDS_PER_TOWER ;i++)
			tower.set( i, deck.pop() );
		
		currentCard = deck.pop();
		
		updateUI();
	}
	
	public void doPlayerTurn(){
		if(gameover)
			return;
		
		// Value of highlighted card
		Integer value = new Integer( ((TowerJPanel)towerPanel).highlightedLabel.getText() );
		// Index of card in the tower array
		int index = tower.indexOf(value);
		// Put selected card in tower, put discarded block on top of deck
		deck.push( tower.set(index, currentCard) );
		// Select a new card
		currentCard = deck.pop();
		
		// Refresh UI
		updateUI();
		
		if( solved(tower) ){
			JOptionPane.showMessageDialog(null, "WIN", "hey",
                    JOptionPane.INFORMATION_MESSAGE);
			gameover=true;
			return;
		}
		
		doEnemyTurn();
	}
	
	public void doEnemyTurn(){
		/*// Strategy 1 
	    // Find a % of card, based on amount of cards total
	    double p = (double)currentCard / (double)AMT_CARDS;
	    // Find a key using that index
	    int index = (int)( p * ( (double)(enemy.size()-1.0) ) );
	    */
		
		// Strategy 2
		@SuppressWarnings("unchecked")
		ArrayList<Integer> tmp = (ArrayList<Integer>)enemy.clone();
	    tmp.add( currentCard );
	    Collections.sort(tmp);
	    int index = tmp.indexOf( currentCard );
	    
	    // insert the block where it should go
	    if( index == tmp.size()-1 ){
	    	index = enemy.size()-1;
	    }

		// Put selected card in tower, put discarded block on top of deck
		deck.push( enemy.set(index, currentCard) );
		// Select a new card
		currentCard = deck.pop();
		
		// Refresh UI
		updateUI();
		
		if( solved(enemy) ){
			System.out.println("PC WIN");
			JOptionPane.showMessageDialog(null, "LOSE", "hey",
                    JOptionPane.INFORMATION_MESSAGE);
			gameover=true;
			return;
		}
	}
}