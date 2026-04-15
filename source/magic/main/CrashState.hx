package magic.main;

class CrashState extends MusicBeatState {
    var bg = new FlxSprite();

	public var error:String;
	public var errorName:String;
	public var report:FlxText = new FlxText(0, 0, FlxG.width / 1.5);

    public function new(prevState:FlxState, error:String, errorName:String):Void{
		this.error = error;
		this.errorName = errorName;

		super();

		print('Crash State: ${Type.getClass(FlxG.state)}'.red());
	}

	override public function create(){
		super.create();

		bg.loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
        add(bg);

		var msg:String = 'Magicfork Crashlog...\n\n';
		var error:String = 'Error caught: ${errorName}\n${error}\nPlease message [melodiicam2b.vbs] if this issue persists!';

		report.text = msg + error;
		report.setFormat(Paths.font('system.ttf'), 16, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		report.screenCenter(XY);
		report.borderSize = 1.5;
		report.scrollFactor.set(0, 0);
		add(report);
		print('Crashed from: ${Type.getClass(FlxG.state)}\n\n${report.text}'.yellow());
        print_Crash();
	}

	function print_Crash(){
		var errMsg:String = "";
		var path:String;
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "Log_" + dateNow + ".txt";

		errMsg = report.text;

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
}