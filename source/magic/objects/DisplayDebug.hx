package magic.objects;

class DisplayDebug extends ClickSprFL {
	static var currentFPS:Float = 0;
	static var times:Array<Float> = [];
	static var deltaTimeout:Float = 0;
	static var mem:Float = 0;
	static var memPeak:Float = 0;
	static var text:TextField;
    static var git:String;
	public function new() {
		super(ClientPrefs.data.debugPos[0], ClientPrefs.data.debugPos[1], true);

		text = new TextField();
		text.autoSize = LEFT;
		text.selectable = false;
		text.defaultTextFormat = new TextFormat(Paths.font('vcr.ttf'), 14, 0xffffffff);
		text.mouseEnabled = false;

        setup([text.width.int(), text.height.int()]);
		addChild(text);
        center(text);
        git = 'Commit: ${GitUtil.getNum()} [ ${GitUtil.getHash()} ] on Branch: ${GitUtil.getBranch()}';
        this.visible = false;
	}

	override public function update(deltaTime:Float):Void {
		final currentTime:Float = haxe.Timer.stamp() * 1000;
		times.push(currentTime);
		while (times[0] < currentTime - 1000){
			times.shift();}

		if (deltaTimeout < 50){
			deltaTimeout += deltaTime;
			return;
		}

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;

		text.text = ''
			+ 'FPS: ${Std.int(currentFPS)} - Memory: ${flixel.util.FlxStringUtil.formatBytes(memory)}\n'
			+ 'State: ${Type.getClass(FlxG.state)}\n${git}';
        updateModule([text.width.int(), text.height.int()]);
		center(text);
        deltaTimeout = 0.0;
	}

    public var memory(get, never):Float;
    inline function get_memory():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);

    public var opacity(default, set):Float = 0.6;
    public var padding(default, set):Int = 8;
    public var round(default, set):Int = 6;

    static inline final border_Width:Int = 3;
    static inline final border_Height:Int = 2;

    var background = new Shape();

    public function setup(dimensions:Array<Int>) {
        drawBackground(dimensions);
        background.alpha = opacity;
        addChild(background);
    }

    public function updateModule(dimensions:Array<Int>) {
        background.graphics.clear();
        drawBackground(dimensions);
    }

    public inline function center(object:openfl.display.DisplayObject):Void {
        object.x = border_Width + (padding / 2);
        object.y = border_Height + (padding / 2);
    }

    inline function drawBackground(dimensions:Array<Int>):Void {
        final innerWidth:Int = dimensions[0] + padding;
        final innerHeight:Int = dimensions[1] + padding;
        final outerWidth:Int = innerWidth + (border_Width * 2);
        final outerHeight:Int = innerHeight + (border_Height * 2);

        background.graphics.beginFill(0xff0f0f0f, 1);
        background.graphics.drawRoundRect(0, 0, outerWidth, outerHeight, round, round);
        background.graphics.endFill();

        final roundSmal:Float = round * 0.7;

        background.graphics.beginFill(0xff282828, 1);
        background.graphics.drawRoundRect(border_Width, border_Height, innerWidth, innerHeight, roundSmal, roundSmal);
        background.graphics.endFill();
    }

    function set_padding(value:Int) return padding = value;
    function set_round(value:Int) return round = value;

    function set_opacity(value:Float):Float {
        if (background != null) background.alpha = value;
        return opacity = value;
    }
}