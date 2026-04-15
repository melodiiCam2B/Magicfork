package split;

class Intro extends MusicBeatState { 
    override public function create() {
        Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

        if(Main.game.skipSplash) {

        } else {
            switchState(new Title());
        }
    }
}