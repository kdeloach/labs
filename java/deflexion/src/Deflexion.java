import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.MediaTracker;
import java.awt.Point;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.util.ArrayList;

import javax.swing.JPanel;
import javax.swing.event.MouseInputListener;


public class Deflexion extends JPanel implements MouseInputListener, Runnable, KeyListener
{
    private static final long serialVersionUID = 1L;

    Dimension size = new Dimension(590, 478);

    int[][] field;

    Image[][] images;
    Image bgimage;

    final int A = 0;
    final int B = 1;
    final int C = 2;
    final int D = 3;
    final int E = 4;
    final int F = 5;
    final int G = 6;
    final int H = 7;

    final int PHAROH =  0;
    final int DJED =    1;
    final int PYRAMID = 3;
    final int OBELISK = 7;

    final int SW = 0;
    final int NW = 1;
    final int NE = 2;
    final int SE = 3;
    final int NA = 0;

    final Point DOWN  = new Point(0, 1);
    final Point UP    = new Point(0, -1);
    final Point LEFT  = new Point(-1, 0);
    final Point RIGHT = new Point(1, 0);

    final static int P1 = 0;
    final static int P2 = 1;

    final String[] cz = new String[]{"#D8E9F5", "#EDEDA0"};

    Soldier[][] battlefield;

    boolean loadingImages;
    Thread t;
    int max;
    MediaTracker tracker;
    Toolkit kit;
    Status st;

    ArrayList<Point> laserpath = new ArrayList<Point>();
    int whoseturn;
    double loaded;
    int player;
    
    boolean gameOver;
    Thread thread;
    
    Soldier tmpSoldier;
    boolean down;
    
    boolean firelaser;
    
    Point a, b;

    BufferedImage image;
    Graphics painter;
    
    public Deflexion(Status st)
    {
        this.st = st;
        
        addKeyListener(this);
        addMouseListener(this);
        addMouseMotionListener(this);

        loadImages();
        newGame();
    }

    public void loadImages()
    {
        loadingImages = true;

        kit = Toolkit.getDefaultToolkit();
        tracker = new MediaTracker(this);
        max = 0;

        bgimage = kit.getImage(Execute.class.getResource("images/battlefield_scaled.png"));
        tracker.addImage(bgimage, max);
        max++;

        images = new Image[2][8];

        images[P1] = new Image[] {
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-pharoh_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-djed-1_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-djed-2_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-pyramid-1_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-pyramid-2_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-pyramid-3_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-pyramid-4_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P1) + "-obelisk_scaled.gif")),
        };
        images[P2] = new Image[] {
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-pharoh_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-djed-1_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-djed-2_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-pyramid-1_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-pyramid-2_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-pyramid-3_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-pyramid-4_scaled.gif")),
            kit.getImage(Execute.class.getResource("images/" + getColorString(P2) + "-obelisk_scaled.gif"))
        };

        for(int p = P1; p <= P2; p++)
        {
            for(int i = 0; i < images[p].length; i++)
            {
                tracker.addImage(images[p][i], max);
                max++;
            }
        }

        t = new Thread(this);
        t.start();
    }

    public void run()
    {
        // for preload animation
        if(loadingImages)
        {
            try {
                for(int i = 0; i < max; i++)
                {
                    tracker.waitForID(i);
                    loaded = (double)(i + 1) / (double)max;
                    try {
                        Thread.sleep(5);
                    } catch(Exception e) {
                        //
                    }
                    repaint();
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            loadingImages = false;
            t = null;
            repaint();
            return;
        }

        Point startingpoint;
        Point vel;

        if(firelaser)
        {
            laserpath = new ArrayList<Point>();
            if(whoseturn == P1)
            {
                startingpoint = new Point(56/2, 0);
                vel = DOWN;
            }
            else
            {
                startingpoint = new Point(56 * 9 + 56/2, 56 * 8);
                vel = UP;
            }

            laserpath.add(new Point(startingpoint.x, startingpoint.y));
            
            int speed = 56/2;
            int i = 0;
            
            while(true)
            {
                // get last pos
                Point prevpoint = (Point)(laserpath.get(laserpath.size() - 1));
                int currentx = prevpoint.x + vel.x * speed;
                int currenty = prevpoint.y + vel.y * speed;

                // check bounds
                if(currentx < 0 || currentx >= size.width - 15)
                {
                    break;
                }
                if(currenty < 0 || currenty >= size.height - 15)
                {
                    break;
                }

                laserpath.add(new Point(currentx, currenty));
                repaint();
                
                try { 
                    Thread.sleep(40);
                } catch(Exception e) {
                    //
                }

                if(i++ % 2 == 0)
                {
                    // every 2 turns check to see if we can change vel
                    int x = (currentx - 15) / 56;
                    int y = (currenty - 15) / 56;

                    if(battlefield[y][x] != null)
                    {
                        vel = battlefield[y][x].collision(vel);
                    }

                    // we hit something
                    if(vel == null)
                    {
                        if(battlefield[y][x].typ==PHAROH)
                        {
                            gameOver = true;
                            st.gameOver = true;
                            st.setColor(cz[whoseturn]);
                            st.repaint();
                        }
                        battlefield[y][x] = null;
                        break;
                    }
                }
                repaint();
            }
        }

        firelaser = false;
        laserpath = new ArrayList<Point>();
        thread = null;
        st.setColor(cz[whoseturn]);
        st.repaint();
        repaint();
    }

    public void newGame()
    {
        thread = null;
        whoseturn = P1;
        st.setColor(cz[P1]);
        gameOver = false;
        tmpSoldier = null;
        down = false;
        firelaser = false;
        resetSoldiers();
        repaint();
    }
    
    public void resetSoldiers()
    {
        battlefield = new Soldier[8][10];

        for(int x = 0; x < battlefield.length; x++)
        {
            for(int y = 0; y < battlefield[x].length; y++)
            {
                battlefield[x][y] = null;
            }
        }

        battlefield[C][3] = new Soldier(P1, PYRAMID, NW, this);
        battlefield[D][2] = new Soldier(P1, PYRAMID, SW, this);
        battlefield[D][9] = new Soldier(P1, PYRAMID, NW, this);
        battlefield[E][2] = new Soldier(P1, PYRAMID, NW, this);
        battlefield[E][9] = new Soldier(P1, PYRAMID, SW, this);
        battlefield[G][7] = new Soldier(P1, PYRAMID, NE, this);
        battlefield[H][2] = new Soldier(P1, PYRAMID, NW, this);
        battlefield[E][4] = new Soldier(P1, DJED, NW, this);
        battlefield[E][5] = new Soldier(P1, DJED, SW, this);
        battlefield[H][3] = new Soldier(P1, OBELISK, NA, this);
        battlefield[H][5] = new Soldier(P1, OBELISK, NA, this);
        battlefield[H][4] = new Soldier(P1, PHAROH, NA, this);

        battlefield[F][6] = new Soldier(P2, PYRAMID, SE, this);
        battlefield[E][7] = new Soldier(P2, PYRAMID, NE, this);
        battlefield[E][0] = new Soldier(P2, PYRAMID, SE, this);
        battlefield[D][7] = new Soldier(P2, PYRAMID, SE, this);
        battlefield[D][0] = new Soldier(P2, PYRAMID, NE, this);
        battlefield[B][2] = new Soldier(P2, PYRAMID, SW, this);
        battlefield[A][7] = new Soldier(P2, PYRAMID, SE, this);
        battlefield[D][5] = new Soldier(P2, DJED, NW, this);
        battlefield[D][4] = new Soldier(P2, DJED, SW, this);
        battlefield[A][6] = new Soldier(P2, OBELISK, NA, this);
        battlefield[A][4] = new Soldier(P2, OBELISK, NA, this);
        battlefield[A][5] = new Soldier(P2, PHAROH, NA, this);
    }

    public void keyPressed(KeyEvent e)
    {
        // 37 - left
        // 39 - right
        // 32 - space
        int code = e.getKeyCode();

        if(tmpSoldier != null)
        {
            if(tmpSoldier.typ == PYRAMID)
            {
                if(code==32)
                {
                    int imp = tmpSoldier.prevrot;
                    if(imp<=1)
                    {
                        imp += 2;
                    }
                    else
                    {
                        imp -= 2;
                    }

                    do
                    {
                        tmpSoldier.rot = (tmpSoldier.rot + 1) % 4;
                    }
                    while(tmpSoldier.rot == imp);
                    repaint();
                }
            }
            else if(tmpSoldier.typ == DJED)
            {
                if(code==32)
                {
                    tmpSoldier.rot = (tmpSoldier.rot + 1) % 2;
                    repaint();
                }
            }
        }
    }

    public void keyTyped(KeyEvent e){}
    public void keyReleased(KeyEvent e){}

    public void mousePressed(MouseEvent e)
    {
        if(gameOver)
        {
            return;
        }
        down = true;

        int x = (e.getX() - 15) / 56;
        int y = (e.getY() - 15) / 56;

        int offsetx = e.getX() - (x * 56 + 15);
        int offsety = e.getY() - (y * 56 + 15);

        if(y >= battlefield.length || x >= battlefield[0].length)
        {
            return;
        }

        if(battlefield[y][x] != null && battlefield[y][x].playr == whoseturn)
        {
            if(!battlefield[y][x].ableToMove())
            {
                return;
            }
            tmpSoldier = battlefield[y][x];
            tmpSoldier.tmpoffsetx = offsetx;
            tmpSoldier.tmpoffsety = offsety;
            tmpSoldier.prevrot = tmpSoldier.rot;
            tmpSoldier.prevx = x;
            tmpSoldier.prevy = y;
            tmpSoldier.tmpx = e.getX();
            tmpSoldier.tmpy = e.getY();
            battlefield[y][x] = null;
        }
        repaint();
    }
    
    public void mouseDragged(MouseEvent e)
    {
        if(gameOver)
        {
            return;
        }

        if(down && tmpSoldier != null)
        {
            //int x = (e.getX() - tmpSoldier.tmpoffsetx + 15) / 56;
            //int y = (e.getY() - tmpSoldier.tmpoffsety + 15) / 56;

            if(!tmpSoldier.willGoOutOfBoundsX(e.getPoint()) && tmpSoldier.ableToMoveHereX(e.getY(), e.getX()))
            {
                tmpSoldier.tmpx = e.getX();
            }
            if(!tmpSoldier.willGoOutOfBoundsY(e.getPoint()) && tmpSoldier.ableToMoveHereY(e.getY(), e.getX()))
            {
                tmpSoldier.tmpy =e .getY();
            }
        }
        repaint();
    }

    public void nextTurn()
    {
        if(whoseturn == player && tmpSoldier != null)
        {
            //int x = (tmpSoldier.tmpx - tmpSoldier.tmpoffsetx + 15) / 56;
            //int y = (tmpSoldier.tmpy - tmpSoldier.tmpoffsety + 15) / 56;
            tmpSoldier = null;
        }
        whoseturn = 1 - whoseturn;
        fireLaser();
    }

    public void fireLaser()
    {
        firelaser = true;
        thread = new Thread(this);
        thread.start();
    }

    public void mouseReleased(MouseEvent e)
    {
        if(gameOver)
        {
            return;
        }
        
        down = false;
        boolean next = false;

        if(tmpSoldier != null)
        {
            int x = (tmpSoldier.tmpx-  tmpSoldier.tmpoffsetx + 15) / 56;
            int y = (tmpSoldier.tmpy - tmpSoldier.tmpoffsety + 15) / 56;

            a = new Point(tmpSoldier.prevx * 56, tmpSoldier.prevy * 56); // red
            b = new Point(x * 56, y * 56); // blue

            boolean mvdxy = tmpSoldier.prevx != x || tmpSoldier.prevy != y;
            boolean mvdrt = tmpSoldier.prevrot != tmpSoldier.rot;

            if(mvdxy && battlefield[y][x] != null && !mvdrt)
            {
                if(tmpSoldier.typ == DJED)
                {
                    if(tmpSoldier.isHome(a) && battlefield[y][x].playr != tmpSoldier.playr)
                    {
                        tmpSoldier.gotoPrevTile();
                    }
                    else
                    {
                        tmpSoldier.swapWith(y,x);
                        tmpSoldier = null;
                        repaint();
                    }
                    next = true;
                }
                else
                {
                    tmpSoldier.gotoPrevTile();
                }
            }
            else if(mvdxy && battlefield[y][x] == null && !mvdrt)
            {
                battlefield[y][x] = tmpSoldier;
                next = true;
            }
            else if(!mvdxy && mvdrt)
            {
                battlefield[y][x] = tmpSoldier;
                next=true;
            }
            else
            {
                tmpSoldier.rot = tmpSoldier.prevrot;
                tmpSoldier.gotoPrevTile();
                tmpSoldier = null;
                repaint();
                return;
            }

            if((battlefield[y][x].prevx != x //proceed if they moved horizontally
                || battlefield[y][x].prevy != y //proceed if they moved vertically
                || tmpSoldier.prevrot != tmpSoldier.rot //proceed if the rotation has changed
                ) && next)
            {
                nextTurn();
            }
            tmpSoldier = null;
        }
        repaint();
    }

    public void mouseExited(MouseEvent e){}
    public void mouseEntered(MouseEvent e){}
    public void mouseClicked(MouseEvent e){}
    public void mouseMoved(MouseEvent e){}

    public void update(Graphics g)
    {
        if(image == null)
        {
            image = (BufferedImage)createImage(getWidth(), getHeight());
            painter = image.getGraphics();
        }
        paint(painter);
        g.drawImage(image, 0, 0, this);
    }
    
    public void paint(Graphics g)
    {
        // preload animation
        if(!tracker.checkAll())
        {
            g.setColor(Color.WHITE);
            g.fillRect(0, 0, size.width,size.height);
            g.setColor(Color.BLACK);
            g.drawString("Loading..." + Math.round(loaded * 100.0) + "%", 100, 100);
            g.drawRect(200, 90, 200, 10);
            g.fillRect(200, 90, (int)(200.0 * loaded), 10);
            return;
        }

        g.drawImage(bgimage, 0, 0, this);
        g = g.create(15, 15, size.width, size.height);

        if(firelaser)
        {
            for(int i = 1; i < laserpath.size(); i++)
            {
                Point from = (Point)laserpath.get(i - 1);
                Point to = (Point)laserpath.get(i);
                
                if(i + 1 == laserpath.size())
                {
                    g.setColor(Color.decode("#000000"));
                }
                else
                {
                    g.setColor(Color.decode("#FF0000"));
                }
                g.drawLine(from.x, from.y, to.x, to.y);
            }
        }

        g.setColor(Color.BLACK);

        for(int y = 0; y < battlefield.length; y++)
        {
            for(int x = 0; x < battlefield[y].length; x++)
            {
                if(battlefield[y][x] == null)
                {
                    continue;
                }
                Soldier tmp = battlefield[y][x];
                int pos = tmp.typ + tmp.rot;
                g.drawImage(images[tmp.playr][pos], x * 56, y * 56, this);
            }
        }

        // temporary soldier
        if(tmpSoldier != null)
        {
            // highlight target square
            int x = (tmpSoldier.tmpx - tmpSoldier.tmpoffsetx + 15) / 56;
            int y = (tmpSoldier.tmpy - tmpSoldier.tmpoffsety + 15) / 56;

            int bn = 1;
            g.drawRect(x * 56 + bn, y * 56 + bn, 55 - bn * 2, 55 - bn * 2);

            // draw soldier
            int pos = tmpSoldier.typ + tmpSoldier.rot;
            g.drawImage(images[tmpSoldier.playr][pos], tmpSoldier.tmpx - 15 - tmpSoldier.tmpoffsetx, tmpSoldier.tmpy - 15 - tmpSoldier.tmpoffsety, this);
        }
    }

    public String getColorString(int player)
    {
        switch(player)
        {
            case P1:
                return "silver";
            case P2:
                return "gold";
        }
        return "";
    }

    public Dimension getPreferredSize()
    {
        return size;
    }
}

class Soldier
{
    int playr, typ, rot, prevrot;
    int tmpx, tmpy, tmpoffsetx, tmpoffsety, prevx, prevy;
    Deflexion mastr;

    public Soldier(int playr, int typ, int rot, Deflexion master)
    {
        this.playr = playr;
        this.typ = typ;
        this.rot = rot;
        this.mastr = master;
    }
    
    public String id()
    {
        return new String("" + playr + typ + rot);
    }
    
    public Point collision(Point vel)
    {
        //vel is the direction of the laser 
        if(typ == mastr.OBELISK || typ == mastr.PHAROH)
        {
            return null;
        }
        else if(typ == mastr.DJED)
        {
            if(rot == mastr.SW)
            {
                if(vel == mastr.LEFT) return mastr.UP;
                else if(vel == mastr.UP) return mastr.LEFT;
                else if(vel == mastr.DOWN) return mastr.RIGHT;
                else if(vel == mastr.RIGHT) return mastr.DOWN;
            }
            else if(rot == mastr.NW)
            {
                if(vel == mastr.LEFT) return mastr.DOWN;
                else if(vel == mastr.UP) return mastr.RIGHT;
                else if(vel == mastr.DOWN) return mastr.LEFT;
                else if(vel == mastr.RIGHT) return mastr.UP;
            }
        }
        else if(typ == mastr.PYRAMID)
        {
            if(rot == mastr.NW)
            {
                if(vel == mastr.RIGHT) return mastr.UP;
                else if(vel == mastr.DOWN) return mastr.LEFT;
            }
            else if(rot == mastr.NE)
            {
                if(vel == mastr.LEFT) return mastr.UP;
                else if(vel == mastr.DOWN) return mastr.RIGHT;
            }
            else if(rot == mastr.SE)
            {
                if(vel == mastr.LEFT) return mastr.DOWN;
                else if(vel == mastr.UP) return mastr.RIGHT;
            }
            else if(rot == mastr.SW)
            {
                if(vel == mastr.RIGHT) return mastr.DOWN;
                else if(vel == mastr.UP) return mastr.LEFT;
            }
        }
        return null;
    }
    
    public boolean willGoOutOfBoundsX(Point e)
    {
        int x = e.x - 15;
        int goldoffset=0, silveroffset=0;

        if(mastr.getColorString(playr) == "silver")
        {
            goldoffset = 56;
        }
        else
        {
            silveroffset = 56;
        }
        
        return x - tmpoffsetx - goldoffset < 0 || x + (56 - tmpoffsetx) + silveroffset >= mastr.size.width - 30;
    }
    
    public boolean willGoOutOfBoundsY(Point e)
    {
        int y = e.y - 15;
        return y - tmpoffsety < 0 || y + (56 - tmpoffsety) >= mastr.size.height - 30;
    }
    
    public boolean willGoOutOfBounds(Point e)
    {
        return willGoOutOfBoundsY(e) && willGoOutOfBoundsX(e);
    }
    
    public boolean ableToMove()
    {
        return !mastr.firelaser;
    }
    
    public boolean ableToMoveHere(int y, int x)
    {
        return ableToMoveHereX(y, x) && ableToMoveHereY(y, x);
    }
    
    public boolean ableToMoveHereX(int y, int x)
    {
        return Math.abs((mastr.tmpSoldier.prevx * 56 + mastr.tmpSoldier.tmpoffsetx + 15) - x) <= 56;
    }
    
    public boolean ableToMoveHereY(int y, int x)
    {
        return Math.abs((mastr.tmpSoldier.prevy * 56 + mastr.tmpSoldier.tmpoffsety + 15) - y) <= 56;
    }
    
    // does this piece have homefield advantage?
    public boolean isHome(Point e)
    {
        int x = e.x;

        if(mastr.getColorString(playr) == "silver" && x == 504)
        {
            return true;
        }
        else if(mastr.getColorString(playr) == "gold" && x == 0)
        {
            return true;
        }
        return false;
    }
    
    public void gotoPrevTile()
    {
        mastr.battlefield[prevy][prevx] = this;
    }
    
    public void swapWith(int y, int x)
    {
        Soldier tmp = mastr.battlefield[y][x];
        mastr.battlefield[y][x] = this;
        mastr.battlefield[prevy][prevx] = tmp;
        tmp = null;
    }
}

class Status extends JPanel
{
    private static final long serialVersionUID = 1L;
    
    String c;
    boolean gameOver;

    public Status()
    {
        setSize(getPreferredSize());
    }
    
    public void setColor(String c)
    {
        this.c = c;
        repaint();
    }
    
    public void paint(Graphics g)
    {
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, getWidth(), getHeight());

        if(!gameOver)
        {
            g.setColor(Color.decode(c));
            g.fillRect(80, 5, 50, 15);
            g.setColor(Color.BLACK);
            g.drawString("It's your turn:", 5, 18);
            g.drawRect(80, 5, 50, 15);
        }
        else
        {
            g.setColor(Color.decode(c));
            g.fillRect(20, 5, 50, 15);
            g.setColor(Color.BLACK);
            g.drawString("Wins!", 90, 18);
            g.drawRect(20, 5, 50, 15);
        }
    }
    public Dimension getPreferredSize()
    {
        return new Dimension(140, 25);
    }
    
    public Dimension getMaximumSize()
    {
        return new Dimension(140, 25);
    }
    
    public Dimension getMinimumSize()
    {
        return new Dimension(140, 25);
    }
}
