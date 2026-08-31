package magic;

class Intro extends MusicBeatState { 
    var initiated:Bool = false;
    public function new(initiated:Bool = false):Void {
		super();
        this.initiated = initiated;
	}

    override public function create() {
        super.create();
        if(!initiated){
            Paths.clearStoredMemory();
            Paths.clearUnusedMemory();
            ClientPrefs.loadPrefs();
            Language.reloadPhrases();
            
            if(FlxG.save.data != null && FlxG.save.data.fullscreen)
                FlxG.fullscreen = FlxG.save.data.fullscreen;
                
            persistentUpdate = true;
            persistentDraw = true;

            Mods.pushGlobalMods();
            Mods.loadTopMod();
            StateUtil.loadTopSate();
            DiscordClient.changePresence("In the Menus", null);
            Highscore.load();

            var leDate = Date.now();
            if (leDate.getDay() == 5 && leDate.getHours() >= 18)
                Achievements.unlock('friday_night_play');

            Achievements.reloadList();
            initiated = true;
        }

        MusicBeatState.switchState(new ScriptedState('title'));
        
    }
}