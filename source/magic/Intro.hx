package magic;

class Intro extends MusicBeatState { 
    override public function create() {
        Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();
        ClientPrefs.loadPrefs();
		Language.reloadPhrases();

        if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			
		persistentUpdate = true;
		persistentDraw = true;

        if(Main.game.skipSplash) 
            switchState(new ScriptedState('Startup'));
        else 
            switchState(new ScriptedState('title'));
        
    }
}