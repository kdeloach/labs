import javax.swing.JButton;
import java.awt.Graphics;

public class CustomButton extends JButton
{
	private static final long serialVersionUID = 1L;
	
	public CustomButton(String s)
	{
		super(s);	
	}
	public void paint(Graphics g)
	{
		//super.paintComponent(g);
		
		g.fillOval(0,0,10,10);
	}
}