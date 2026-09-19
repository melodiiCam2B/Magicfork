package magic.objects;
import lime.system.System;

class Module extends Module_Group{
    public var execute:Dynamic->Void;
    public var returning:Dynamic;
    public function new(x:Float = 0, y:Float = 0, text:String, ?func:Dynamic->Void, ?ren:Dynamic) {
        super(x, y);
        execute = func;
        returning = ren;

        add(new Module_Sprite(0, 0, 300, 60, 0.6));
        add(new Module_Text(47, 50, text, 0.8));
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera))
            if (execute != null) execute(returning);
    }
}