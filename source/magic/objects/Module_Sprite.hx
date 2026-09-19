package magic.objects;
import lime.system.System;

class Module_Sprite extends SkewSpr{
    public var execute:Void->Void;
    public function new(x:Float, y:Float, w:Int, h:Int, alpha:Float, color:FlxColor = 0xff393939){
        super(x, y);
        makeGraphic(w, h, FlxColor.TRANSPARENT, true);
        drawrect(0, 0, w, h, 11 * 2, color);
        updateHitbox();
        this.alpha = alpha;
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera))
            if (execute != null) execute();
    }

    function drawrect(x:Float, y:Float, w:Int, h:Int, c:Float, i:FlxColor)
        FlxSpriteUtil.drawRoundRectComplex(this, x, y, w, h, c, c, c, c, i);
}