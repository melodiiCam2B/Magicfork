package magic.hscript;

class LogBar extends SkewSpr {
    public final onClick:Void->Void;
    public function new(onClick:Void->Void) {
        super();
        makeGraphic(700, 20, 0x43ffffff, true);
        updateHitbox();
        this.onClick = onClick;
    }

    var clickTimer:Float = 0;
    var doubleClickDelay:Float = 0.3;
    override function update(elapsed:Float) {
        super.update(elapsed);

        if (clickTimer > 0) 
            clickTimer -= elapsed;

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera)) {
            if (clickTimer > 0) {
                if (onClick != null) onClick();
                clickTimer = 0; 
            } else 
                clickTimer = doubleClickDelay;
        }
    }
}