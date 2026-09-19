package magic.utils;
/**
 * middle man state that prevents crashes
 * it stores a map of hard code states it defaults too
 */
class StateCheck extends MusicBeatSubstate {
    var instance:String;
    public function new(instance:String) {
        super();
        this.instance = instance;
        if(FileSystem.exists(instance))
            nextState(new ScriptedState(instance));
        else
            nextState(redirectMap.get('$instance'));
    }

    public static var redirectMap:Map<String, FlxState> = [
        'mainMenu'  => new states.MainMenuState(),
        'storyMode' => new states.StoryMenuState(),
        'freePlay'  => new states.FreeplayState(),
        'credits'   => new states.CreditsState(),
        'options'   => new options.OptionsState(),
        'title'     => new states.TitleState()
    ];

    public static function nextState(state:FlxState)
        MusicBeatState.switchState(state);
}