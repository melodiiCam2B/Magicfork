package magic.objects;
import lime.system.System;

class Module_Icon extends SkewSpr{
    public var execute:Void->Void;
    public function new(x:Float = 0, y:Float = 0,  w:Int, h:Int, icon:String, ?func:Void->Void) {
        super(x, y);
        execute = func;

        loadGraphic(Get.image(icon));
		setGraphicSize(w, h);
        setColorTransform(1.0, 1.0, 1.0, 1.0, 255, 255, 255);
		updateHitbox();
    }

    override function update(elapsed:Float){
		super.update(elapsed);

        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera))
            if (execute != null) execute();
    }
}