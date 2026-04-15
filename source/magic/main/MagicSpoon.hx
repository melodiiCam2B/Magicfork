package magic.main;

class MagicSpoon extends FlxGame {
	private static function crashGame() {
		null.draw();
	}

	override function create(_):Void {
		try
			super.create(_)
		catch (e)
			onCrash(e);
	}

	override function onFocus(_):Void {
		try
			super.onFocus(_)
		catch (e)
			onCrash(e);
	}

	override function onFocusLost(_):Void {
		try
			super.onFocusLost(_)
		catch (e)
			onCrash(e);
	}


	override function onEnterFrame(_):Void {
		try
			super.onEnterFrame(_)
		catch (e)
			onCrash(e);
	}

	override function update():Void {
        #if debug
		if (FlxG.keys.justPressed.F1)
			crashGame();
        #end	

		try
			super.update()
		catch (e)
			onCrash(e);
	}

	override function draw():Void {
		try
			super.draw()
		catch (e)
			onCrash(e);
	}

	private final function onCrash(e:haxe.Exception):Void {
		var emsg:String = "";
		for (stackItem in haxe.CallStack.exceptionStack(true)) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					emsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
					trace(stackItem);
			}
		}

		FlxG.switchState(() -> new CrashState(FlxG.state, emsg, e.message));
	}
}