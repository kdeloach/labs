package net.kevinx.labs.flash.manover
{
    import net.kevinx.labs.flash.manover.pieces.*;
    import org.flixel.*;

    public class PlayState extends FlxState
    {
        public var controls:PuzzleBox;
        public var player:Player;
        public var ground:FlxSprite;
        public var wall1:FlxSprite;
        public var wall2:FlxSprite;
        
        override public function create():void
        {
            FlxG.bgColor = FlxG.WHITE;
            FlxG.mouse.show();
                    
            ground = new FlxSprite(0, FlxG.height / 4 - 5);
            ground.makeGraphic(FlxG.width / 2, 5, 0xFFBBBBBB);
            ground.immovable = true;
            add(ground);

            wall1 = new FlxSprite(0, 0);
            wall1.makeGraphic(5, FlxG.width / 4, 0xFFBBBBBB);
            wall1.immovable = true;
            add(wall1);

            wall2 = new FlxSprite(FlxG.width / 2 - 5, 0);
            wall2.makeGraphic(5, FlxG.width / 4, 0xFFBBBBBB);
            wall2.immovable = true;
            add(wall2);
            
            controls = new PuzzleBox(0, FlxG.height / 4, FlxG.width / 2, FlxG.height / 4);
            controls.add(new W());
            controls.add(new A());
            controls.add(new S());
            controls.add(new D());
            controls.add(new Space());
            controls.add(new DoubleTap());
            controls.add(new DoubleTap());
            controls.add(new Always());
            controls.add(new Jump());
            controls.add(new Attack());
            controls.add(new MoveLeft());
            controls.add(new MoveRight());
            controls.add(new Shift());
            //controls.add(new PuzzlePiece("Dash", 3));
            //controls.add(new PuzzlePiece("Dash", 3));
            //controls.add(new PuzzlePiece("Toggle", 4));
            add(controls);
            
            player = new Player(this, controls.playerController);
            player.x = FlxG.width / 4 - player.width / 2;
            player.y = 0;
            add(player);
        }
        
        override public function update():void 
        {
            super.update();
            FlxG.collide(player, ground);
            FlxG.collide(player, wall1);
            FlxG.collide(player, wall2);
        }
    }
}