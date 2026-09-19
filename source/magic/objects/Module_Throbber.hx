package magic.objects;
import lime.system.System;

class Module_Throbber extends FlxSprite {
    public function new(X:Float = 0, Y:Float = 0, alpha:Float, color:FlxColor = 0xffbababa) {
        super(X, Y);

        makeGraphic(40, 40, FlxColor.TRANSPARENT);
        var lineStyle:LineStyle = { thickness: 4, color: color };
        var drawStyle:DrawStyle = { smoothing: true };
        FlxSpriteUtil.drawCircle(this, 20, 20, 15, FlxColor.TRANSPARENT, lineStyle, drawStyle);
        centerOffsets();
        centerOrigin();
        this.alpha = alpha;
    }

    var timer:Float = 0;
    var tickRate:Float = 0.1;

    override public function update(elapsed:Float):Void {
        timer += elapsed;
        if (timer >= tickRate) {
            angle += 45; 
            timer = 0;
        }
        super.update(elapsed);
    }
}