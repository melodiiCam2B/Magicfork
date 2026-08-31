package magic.main;

class CrashState extends MusicBeatState {
	var bg = new FlxSprite();

	public var error:String;
	public var errorName:String;
	public var report:FlxText = new FlxText(0, 0, FlxG.width / 1.5);

	override public function create(){
		super.create();
		persistentUpdate = persistentDraw = true;

		bg.loadGraphic(Paths.image('menuBlack'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
        add(bg);
		bg.alpha = 0.4;

		var msg:String = 'Magicfork Crashlog\n\n';
		var error:String = 'Error caught: ${errorName}\n${error}\nPress [space] to go back\nPlease message [melodiicam2b.vbs] if this issue persists!';

		report.text = msg + error;
		report.setFormat(Paths.font('main.ttf'), 34, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		report.screenCenter(XY);
		report.borderSize = 1.5;
		report.scrollFactor.set(0, 0);
		add(report);
	}

	override function update(elapsed:Float){
		if (FlxG.keys.justPressed.SPACE) FlxG.switchState(new Intro(false));
		super.update(elapsed);
	}

    public function new(prevState:FlxState, error:String, errorName:String):Void {
		super();
		// print_Crash(prevState, error, errorName);
		print('[${Date.now().toString()}] - ${Type.getClass(prevState)}\n\n${errorName}\n${error}'.yellow());

		this.error = error;
		this.errorName = errorName;
	}

	function print_Crash(prevState:FlxState, error:String, errorName:String) {
		var newCrash:CrashData = {
			name: errorName,
			error: error,
			date: Date.now().toString(),
			state: '${Type.getClass(prevState)}'
		}

		var saveVar:String = "";
		var path:String;
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "Log_" + dateNow + ".json";

		saveVar = haxe.Json.stringify(newCrash, "\t");

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, saveVar);
	}
}

typedef CrashData = {
	var name:String;
	var error:String;
	var date:String;
	var state:String;
}

