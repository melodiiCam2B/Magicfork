package magic.utils;

class CrashLog  extends MusicBeatState {
    var bg = new FlxSprite();
	var mainTab:Module_Sprite;
	var mainName:Module_Text;
	var mainLog:Module_Text;
	var mainDate:Module_Text;

	var mainGroup = new Module_Group();
	var tabGroup = new Module_Group();
	var pressedAccept:Bool = false;
    public static var curSelected:Int = 0;

	override public function create() {
		parseCrashLogs();
        persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBlack'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		makeTabs();
        super.create();
		add(tabGroup);

		setUp_UI();
		mainGroup.screenCenter();
		mainGroup.x = FlxG.width - mainGroup.width;
		add(mainGroup);
		_change_();
	}

	function setUp_UI() {
		mainTab = new Module_Sprite(0, 0, Std.int(FlxG.width/3), Std.int(FlxG.height - (FlxG.height/4)), 0.8);
		mainGroup.add(mainTab);

		mainName = new Module_Text(10, 40, 'Null Object Reference', 1);
		mainGroup.add(mainName);

		mainLog = new Module_Text(10, mainName.height + mainName.y, 'Null Object Reference', 1);
		mainGroup.add(mainLog);

		mainDate = new Module_Text(10, mainTab.height, 'Null Object Reference', 1);
		mainGroup.add(mainDate);
	}

	function makeTabs() {
		for (i => errorLog in errorList) {
			var temp:CrashData = errorList[i];
			tabGroup.add( new Module_Tab(20, 25 * (i * 70), temp.name, temp.date) );
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.mouse.wheel != 0) _change_(-FlxG.mouse.wheel);
        if(controls.UI_UP_P || controls.UI_DOWN_P) _change_(controls.UI_UP_P? -1 : 1);
	}

	function _change_(change:Int = 0) {
		curSelected = FlxMath.wrap(curSelected + change, 0, errorList.length - 1);

		curCrash = errorList[curSelected];
        mainName.text = curCrash.name;
        mainLog.text = curCrash.error;
		mainDate.text = curCrash.date;
	}

	public static var curCrash:CrashData;
	public static var errorList:Array<CrashData> = [];
	public static var tracker:Array<String> = [];

	function parseCrashLogs(){
		if(FileSystem.exists('crash/')) {
			for (file in FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if(tracker.contains(file)) continue;
				if (path.contains('.json')) {
					var newCrash:CrashData = Json.parse(File.getContent(path));
					if(!errorList.contains(newCrash))
						errorList.push(newCrash);
					tracker.push(file);
					
				}
			}
		}
	}
}