package magic.objects;
import openfl.geom.Rectangle;
class ClickSprFL extends Sprite {
    public var drag:Bool;
    public var bounds:Rectangle;
    public function new(?x:Float, ?y:Float, ?drag:Bool = false) {
        super();
        this.visible = false;
        this.x = x;
		this.y = y;
        this.drag = drag;
        if(drag) bounds = new Rectangle(0, 0, FlxG.width, FlxG.height);
    }

    override function __enterFrame(deltaTime:Float):Void {
        if(drag) {
            if(mouse_down) startDrag(false, bounds);
            if(mouse_up) stopDrag();
            update_pos(deltaTime);
        }

        update(deltaTime);
    }

    static var deltaTimeout:Float = 0;

	private function update_pos(deltaTime:Float):Void {
		if (deltaTimeout < 2500){
			deltaTimeout += deltaTime;
			return;
		}

		Reflect.setProperty(ClientPrefs.data, "debugPos", [x, y]);

        ClientPrefs.saveSettings();

        deltaTimeout = 0.0;
	}

    
    public function update(elpased:Float):Void {}

    var clickTimer:Float = 0;

    public var mouse_up(get, never):Bool;
	private function get_mouse_up() return FlxG.mouse.released;

    public var mouse_down(get, never):Bool;
	private function get_mouse_down() return FlxG.mouse.justPressed;

     public var mouse_move(get, never):Bool;
	private function get_mouse_move() return FlxG.mouse.justMoved;
}