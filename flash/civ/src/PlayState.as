package  
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.engine.BreakOpportunity;
    import org.flixel.FlxBasic;
    import org.flixel.FlxCamera;
    import org.flixel.FlxG;
    import org.flixel.FlxGroup;
    import org.flixel.FlxObject;
    import org.flixel.FlxParticle;
    import org.flixel.FlxPoint;
    import org.flixel.FlxRect;
    import org.flixel.FlxSprite;
    import org.flixel.FlxState;
    import events.GameEvent;
    
    public class PlayState extends FlxState
    {    
        public var map:Map;
        public var mapGenerator:MapGenerator;
        
        public var players:Array;
        
        public function PlayState() 
        {
            super();
        }
        
        override public function create():void 
        {
            FlxG.mouse.show();
            
            mapGenerator = new MapGenerator();
            genmap();
            
            players = new Array();
            players[0] = new Player(map);
            //players[1] = new CpuPlayer(map);
            
            var playersReady:uint = 0;
            for each (var p:Player in players)
            {
                p.addEventListener(GameEvent.READY_TO_PLAY, function(evt:GameEvent):void {
                    playersReady++;
                    if (playersReady == players.length)
                    {
                        startGame();
                    }
                });
                p.placeStartingCity();
            }
        }
        
        override public function update():void 
        {
            super.update();
            if (FlxG.keys.justPressed("R"))
            {
                genmap();
            }
            for each (var p:Player in players)
            {
                p.update();
            }
        }
        
        public function genmap():void
        {
            for each(var b:FlxBasic in members)
            {
                b.kill();
            }
            map = mapGenerator.createRandomMap();
            add(map);
        }
        
        public function startGame():void
        {
            trace("START GAME");
            //players[0].placeStartingCity();
        }
    }
}