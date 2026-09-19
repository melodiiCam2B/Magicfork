package magic.hscript;

class LogGroup extends FlxGroup {
	private var debug:FlxTypedGroup<LogText>;
    public function new() {
        super();
		debug = new FlxTypedGroup<LogText>();
		add(debug);
		// add(new LogBar(clickEvent));
    }

	public function addLog(text:String, color:FlxColor) {
		var newText = new LogText();
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		debug.add(newText);
	}

	public function clickEvent():Void {
        for ( i => added in debug.members ) 
            added.visible = !added.visible;
    }
}