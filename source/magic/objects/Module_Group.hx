package magic.objects;
import lime.system.System;

class Module_Group extends FlxSpriteGroup{
    public var focused:Bool = false;
    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

    function centerToMidpoint(target:FlxObject, midPoint:FlxObject, ?axis:Int = 0x11){
        if( axis == 0x01 || axis == 0x11 )
            target.x = midPoint.x + (midPoint.width - target.width) / 2;
        if( axis == 0x10 || axis == 0x11 )
            target.y = midPoint.y + (midPoint.height - target.height) / 2;
    }

    private var _draggingPos:FlxPoint;
	private var _draggingPoint:FlxPoint;
    private var dragging:Bool = false;
    private var hasDragging:Bool = false;
    private var dragTarget:FlxObject;

	override function update(elapsed:Float){
		super.update(elapsed);
        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(this, camera)) focused = true;
        if(FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this, camera)) focused = false;
        
        if(hasDragging && focused){
            if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(dragTarget, camera)) dragging = true;
            if(FlxG.mouse.justReleased && dragging) dragging = false;
            
            if(dragging){
                var newPoint:FlxPoint = FlxG.mouse.getPositionInCameraView(camera);
                setPosition(_draggingPos.x - (_draggingPoint.x - newPoint.x), _draggingPos.y - (_draggingPoint.y - newPoint.y));
            }else{
                _draggingPos = FlxPoint.weak(x, y);
                _draggingPoint = FlxG.mouse.getPositionInCameraView(camera);
            }
        }
    }
}