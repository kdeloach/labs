import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class Main extends JApplet
{
    private static final long serialVersionUID = 1L;

    final static int AMT_CARDS = 42;
    final static int CARDS_PER_TOWER = 10;

    final int towerHorizontalPadding = 4;

    // Holds all the cards- or "blocks" -towers can use
    Stack<Integer> deck;

    // Towers
    ArrayList<Integer> tower, enemy;

    // Shows current card for this round
    Integer currentCard;

    boolean gameover = false;

    JPanel towerPanel, enemyPanel;
    JPanel cardSelectionPanel;
    JLabel currentCardLabel;
    JButton newCardBtn;

    public static void main(String[] argv)
    {
    }

    public void init()
    {
        deck = new Stack<Integer>();
        for(int i = 0; i < AMT_CARDS; i++)
        {
            deck.add(i+1);
        }
        Collections.shuffle(deck);

        tower = new ArrayList<Integer>(CARDS_PER_TOWER);
        enemy = new ArrayList<Integer>(CARDS_PER_TOWER);
        for(int i = 0; i < CARDS_PER_TOWER; i++)
        {
            tower.add(deck.pop());
            enemy.add(deck.pop());
        }

        currentCard = deck.pop();

        renderUI();
    }

    // Returns true if tower is sorted lowest to highest
    public boolean solved(ArrayList<Integer> tower)
    {
        Integer n = 0;
        for(Integer v : tower)
        {
            if(v < n)
            {
                return false;
            }
            n = v;
        }
        return true;
    }

    public void drawCard()
    {
        deck.add(deck.size(), currentCard);
        currentCard = deck.remove(0);
        updateUI();
    }

    @SuppressWarnings("serial")
    public void renderUI()
    {
        // Applet Background Color
        setBackground(new Color(0xE0, 0xEC, 0xFF));
        setSize(400, 375);

        cardSelectionPanel = new JPanel();
        cardSelectionPanel.setLayout(new BoxLayout(cardSelectionPanel, BoxLayout.Y_AXIS));
        cardSelectionPanel.setAlignmentX(JPanel.CENTER_ALIGNMENT);

        currentCardLabel = new CardLabel(currentCard.toString()) {
            public Dimension getPreferredSize()
            {
                return new Dimension(50, 50);
            }
        };
        currentCardLabel.setFont(new Font("Dialog", Font.PLAIN, 32));
        currentCardLabel.setCursor(Cursor.getDefaultCursor());

        newCardBtn = new JButton("Draw Card");
        newCardBtn.setAlignmentX(JPanel.CENTER_ALIGNMENT);
        newCardBtn.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e)
            {
                drawCard();
            }
        });

        cardSelectionPanel.add(currentCardLabel);
        cardSelectionPanel.add(Box.createVerticalStrut(15));
        cardSelectionPanel.add(newCardBtn);

        towerPanel = new TowerJPanel(this) {
            public void mouseClicked(MouseEvent e)
            {
                doPlayerTurn();
            }
        };
        towerPanel.addMouseListener((MouseListener)towerPanel);
        towerPanel.addMouseMotionListener((MouseMotionListener)towerPanel);
        towerPanel.setLayout(new BoxLayout(towerPanel, BoxLayout.Y_AXIS));

        enemyPanel = new TowerJPanel(this);
        enemyPanel.setLayout(new BoxLayout(enemyPanel, BoxLayout.Y_AXIS));

        for(int i=0,l=tower.size(); i < l; i++)
        {
            towerPanel.add(Box.createVerticalStrut((int)(towerHorizontalPadding/2)));
            towerPanel.add(new CardLabel(tower.get(i).toString()));
            towerPanel.add(Box.createVerticalStrut((int)(towerHorizontalPadding/2)));

            enemyPanel.add( Box.createVerticalStrut( (int)(towerHorizontalPadding/2)));
            CardLabel c = new CardLabel( enemy.get(i).toString());

            c.setCursor(Cursor.getDefaultCursor());
            enemyPanel.add(c);
            enemyPanel.add(Box.createVerticalStrut((int)(towerHorizontalPadding/2)));
        }

        setLayout(new GridBagLayout());
        GridBagConstraints c = new GridBagConstraints();
        c.insets = new Insets(5, 5, 5, 5);
        c.weighty = 1;
        c.weightx = 1;

        c.gridx = 0;
        c.gridy = 0;
        c.gridheight = 3;
        c.gridwidth = 1;
        add(enemyPanel, c);

        c.gridx = 1;
        c.gridy = 1;
        c.gridheight = 1;
        c.gridwidth = 1;
        add(cardSelectionPanel, c);

        c.gridx = 2;
        c.gridy = 0;
        c.gridheight = 3;
        c.gridwidth = 1;
        add(towerPanel, c);
    }

    public void updateUI()
    {
        for(int i = 0, len = tower.size(); i < len; i++)
        {
            // Each label component has a Filler component above and below
            // So the layout looks like this: filler, label, filler, filler, label, filler, filler, etc.
            JLabel l = (JLabel)towerPanel.getComponent(i * 3 + 1);
            l.setText(tower.get(i).toString());
            ((JLabel)enemyPanel.getComponent(i * 3 + 1)).setText(enemy.get(i).toString());
        }
        towerPanel.validate();
        enemyPanel.validate();

        currentCardLabel.setText(currentCard.toString());
    }

    public void newGame()
    {
        gameover = false;
        for(Integer n : tower)
        {
            deck.push(n);
        }
        deck.push(currentCard);
        Collections.shuffle(deck);
        for(int i = 0; i < CARDS_PER_TOWER; i++)
        {
            tower.set(i, deck.pop());
        }
        currentCard = deck.pop();
        updateUI();
    }

    public void doPlayerTurn()
    {
        if(gameover)
        {
            return;
        }

        Integer value = new Integer(((TowerJPanel)towerPanel).highlightedLabel.getText());
        int index = tower.indexOf(value);
        deck.push(tower.set(index, currentCard));
        currentCard = deck.pop();

        updateUI();

        if(solved(tower))
        {
            JOptionPane.showMessageDialog(null, "WIN", "hey", JOptionPane.INFORMATION_MESSAGE);
            gameover = true;
            return;
        }

        doEnemyTurn();
    }

    public void doEnemyTurn()
    {
        /*
        // Strategy 1
        // Find a % of card, based on amount of cards total
        double p = (double)currentCard / (double)AMT_CARDS;
        // Find a key using that index
        int index = (int)( p * ( (double)(enemy.size()-1.0) ) );
        */

        // Strategy 2
        @SuppressWarnings("unchecked")
        ArrayList<Integer> tmp = (ArrayList<Integer>)enemy.clone();
        tmp.add(currentCard);
        Collections.sort(tmp);
        int index = tmp.indexOf(currentCard);

        // insert the block where it should go
        if(index == tmp.size() - 1)
        {
            index = enemy.size() - 1;
        }

        deck.push(enemy.set(index, currentCard));
        currentCard = deck.pop();

        updateUI();

        if(solved(enemy))
        {
            System.out.println("PC WIN");
            JOptionPane.showMessageDialog(null, "LOSE", "hey", JOptionPane.INFORMATION_MESSAGE);
            gameover = true;
            return;
        }
    }
}
