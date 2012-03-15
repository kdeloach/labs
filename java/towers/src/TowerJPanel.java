import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.Component;
import javax.swing.JPanel;


public class TowerJPanel extends JPanel implements MouseListener, MouseMotionListener {

	private static final long serialVersionUID = 1L;

	// Currently highlighted label
	public CardLabel highlightedLabel=null;
	
	Main parent;
	
	public TowerJPanel(Main parent) {
		super();
		this.parent=parent;
	}

	/*
	public Dimension getPreferredSize(){
		Dimension s = super.getPreferredSize();
		s.width=CardLabel.MAX_WIDTH+10+60;
		return s;
	}*/
	
	public void mouseClicked(MouseEvent e) {
	}
	public void mouseEntered(MouseEvent e) {
	}
	public void mouseExited(MouseEvent e) {
		if(highlightedLabel != null){
			highlightedLabel.setHighlight(false);
			highlightedLabel.repaint();
			highlightedLabel=null;
		}
	}
	public void mousePressed(MouseEvent e) {
	}
	public void mouseReleased(MouseEvent e) {
	}
	public void mouseDragged(MouseEvent e) {
	}
	public void mouseMoved(MouseEvent e) {
		Component c = this.getComponentAt(e.getX(), e.getY());
		if(c instanceof CardLabel && !c.equals(highlightedLabel)){
			
			if(highlightedLabel != null){
				highlightedLabel.setHighlight(false);
				highlightedLabel.repaint();
			}
			
			highlightedLabel = (CardLabel)c;
			highlightedLabel.setHighlight(true);
			highlightedLabel.repaint();
		}
	}
}
