package magic.dialogue;

class TalkBox extends FlxSpriteGroup {
    var pos = new SkewSpr();
    var box = new SkewSpr();
    var dialogue = new FlxText();
    var data:DialogueData;
    var cap:Int = -1;
    // current array position - cap, shortened for readibility
    public function new(dataPath:String) {
        super(0, 0);
        pos.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        add(pos);
        
        if(data.assets.box != null || data.assets.box != '')
		    box.loadGraphic(Paths.image(data.assets.box));
        else
            drawrect(1163, 330, 11 * 2, 0xff1d1d1d);
        box.updateHitbox();    
		box.antialiasing = ClientPrefs.data.antialiasing;
        box.screenCenter();
        box.y = FlxG.height - (box.height + 50);
		add(box);
        add(dialogue);
    }

    function parse(dataPath:String) {
        var path:String = Mods.checkForStates(Paths.getSharedPath(), 'data/dialogue/$dataPath.json');
		data = Json.parse(dataPath.getText());
    }

    function update_text(change:Int = 0) {
        cap = FlxMath.wrap(cap + change, 0, data.dialogue.length - 1);

		dialogue.setFormat(Paths.font('display.ttf'), 35, data.dialogue[cap].color);
        typeText(data.dialogue[cap].text, data.dialogue[cap].talkType.speed, data.dialogue[cap].talkType.sound);
    }

    function drawrect(w:Int, h:Int, c:Float, i:FlxColor){
        box.makeGraphic(w, h, FlxColor.TRANSPARENT, true);
        FlxSpriteUtil.drawRoundRectComplex(box, 0, 0, w, h, c, c, c, c, i);
    }

    var curText(default, set):String;
    function set_curText(s:String) {
        dialogue.text = curText = s;
        return curText;
    }

    public function typeText(txt:String, speed:Int = 0.04, sound:String) {
        new FlxTimer().start(speed, function(tmr:FlxTimer) {
            curText += txt.charAt(curText.length + 1);

            if(sound != null || sound != '')
                FlxG.sound.play(Paths.sound(sound), 0.8);

            if (curText.length >= txt.length) 
                tmr.cancel();

        }, txt.length);
    }
}

typedef DialogueData = {
	// kinda important I think
	var assets:DialogueAssets;
	// per dialogue line!!!
	var dialogue:Array<Dialogue>;
}

typedef Dialogue = {
	// doesn't call actuall characters because it isn't needed
	var character:String;
	// what they say because that's important
	var text:String;
	// variables for things that are probably important
	var talkType:DialogueType;
    // if empty won't change the music
    @:optional var music:String;
    // text color
    @:optional var color:Int; 
    // the font is optial, because I feel like it
    @:optional var font:String; 
}

typedef DialogueAssets = {
    // actual dialgue box
	@:optional var box:String;
    // if there should be a background
    @:optional var background:DialogueBackground;
}

typedef DialogueType = {
    //  -1 is instant
	var speed:Int; 
	// if you want voiced dialogue, or just beeps
	@:optional var sound:String;
}

typedef DialogueBackground = {
    // transparentcy
	var alpha:Int;
    // actual image name + path
	var image:String;
}

