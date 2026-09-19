package magic.launcher;

class State extends FlxState{
    public function new() {
        super();

        FlxG.autoPause = false;
		FlxG.mouse.visible = true;
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		Lib.current.stage.window.borderless = true;
		Lib.current.stage.window.resizable = false;
    }
    override function create() {
        add(new Module_Dragbar(0, 0, FlxG.width, FlxG.height, 0));
    }
}