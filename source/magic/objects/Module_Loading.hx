package magic.objects;
import lime.system.System;

class Module_Loading extends Module_Group{
    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);

        add(new Module_Sprite(0, 0, 50, 50, 0.6, 0xff424242));
        add(new Module_Throbber(5, 5, 0.8));
    }
}