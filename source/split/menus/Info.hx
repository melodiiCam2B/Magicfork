package split.menus;
/**
 * state for explaining WHAT magic spoon is !!!
 * 
 * Magic spoon is a fork of psych engine 1.0.4 that aims to make modding easier
 * as well as allowing better animation atlas usage (maybe)
 * 
 * + credits maybe?
 */
class Info extends MusicBeatState { 
    override public function create() {
        super.create();
        hscript = null;
        softcoded = false
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}
