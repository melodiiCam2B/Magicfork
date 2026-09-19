package magic.dialogue;
/**
 * todo: dialogue editor
 * - remove file dialogue window, not needed instead auto save to: 'data/dialogue/$dataPath.json'
 * - make editing easy
 * - add a drop down for all possible dialogue files (exclusive to the current mod directory)
 * - allow for multiple endings to dialogue
 * - allow each dialogue file to have an infinite amount of endings
 */
class DialogueTest extends MusicBeatState {
    override function create() {
        FlxG.mouse.visible = persistentUpdate = persistentDraw = true;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBlack'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        super.create();   
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}