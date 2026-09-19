package magic.objects;
import lime.system.System;

class Module_Dragbar extends SkewSpr{
    public function new(x:Float, y:Float, w:Int, h:Int, alpha:Float){
        super(x, y);
        makeGraphic(w, h, 0xff393939, true);
        updateHitbox();
        this.alpha = alpha;
    }

    var isDragging = false;
    private var _lastGlobalX:Float = 0;
    private var _lastGlobalY:Float = 0;
    private var _skipFrame:Bool = false;

    override function update(elapsed:Float) {
        super.update(elapsed);

        var win = Lib.current.stage.window;
        var globalMouseX:Float = win.x + (Lib.current.stage.mouseX * win.scale);
        var globalMouseY:Float = win.y + (Lib.current.stage.mouseY * win.scale);

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera)) {
            isDragging = true;
            _lastGlobalX = globalMouseX;
            _lastGlobalY = globalMouseY;
        }
        
        if (FlxG.mouse.justReleased) 
            isDragging = false;
        
        _skipFrame = !_skipFrame;
        if (_skipFrame) return;

        if (isDragging) {
            var dx = globalMouseX - _lastGlobalX;
            var dy = globalMouseY - _lastGlobalY;

            if (Math.abs(dx) < 200 && Math.abs(dy) < 200) { 
                if (Math.abs(dx) > 1.2 || Math.abs(dy) > 1.2) {
                    win.x += Std.int(dx);
                    win.y += Std.int(dy);
                }
            }

            _lastGlobalX = globalMouseX;
            _lastGlobalY = globalMouseY;
        }
    }
}