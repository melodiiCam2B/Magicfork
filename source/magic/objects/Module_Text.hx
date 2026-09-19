package magic.objects;
import lime.system.System;

class Module_Text extends FlxText{
    public function new(x:Float, y:Float, text:String, alpha:Float){
        super(x, y);
        this.text = text;
		this.setFormat(Get.font('display'), 35, 0xffffffff);
        this.y -= this.height;
        updateHitbox();
        this.alpha = alpha;
    }
}