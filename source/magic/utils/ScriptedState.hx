package magic.utils;

class ScriptedState extends MusicBeatState {
	public var hscript:HScript = null;
	public var stateName:String;
	private var state_id:String;
	
	public var detailsShow(default, set):Bool = true;
	function set_detailsShow(b:Bool):Bool
		return fnfVer.visible = detailsShow = b;

	public static var instance:ScriptedState;
    public function new(name:String):Void{
		state_id = name;
		stateName = StateUtil.modStates.exists(name) ? StateUtil.modStates.get(name) : name;
		super(name);
		instance = this;
		StateUtil.instance = instance;
	}
	var fnfVer:FlxText;

    override function create() {
        persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBlack'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		bg.alpha = 0.4;

        super.create();

		var scriptPath:String = StateUtil.checkForStates(Paths.getSharedPath(), 'data/states/${stateName}.hx');
		if(FileSystem.exists(scriptPath)) {
			try {
				hscript = new HScript(null, scriptPath);
			}catch(e:IrisError) {
				var pos:HScriptInfos = cast {fileName: scriptPath, showLine: false};
				Iris.error(Printer.errorToString(e, false), pos);
			}
		}else{
			print('$stateName script [ $scriptPath ] not found.'.blue());
		}
		
		// if(hscript != null) setup_debug();

		if(hscript != null) {
			setUp_scripted();
			callOnScripts('onCreate');
			callOnScripts('create');
		}

		print('${Type.getClass(FlxG.state)} as $stateName [${Date.now().toString()}]'.blue());

		fnfVer = new FlxText(12, FlxG.height - 24, 0, "Magicfork " + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("genshin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);


		if (controls.justPressed('debug_1') && state_id == 'main') 
			MusicBeatState.switchState(new MasterEditorMenu());

        callOnScripts('onUpdate', [elapsed]);
		callOnScripts('update', [elapsed]);
	}

	override public function stepHit():Void {
		super.stepHit();

        setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
		callOnScripts('stepHit');
	}

	override public function beatHit():Void {
		super.beatHit();

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
		callOnScripts('beatHit');
	}
	
    public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null) {
		if(hscript != null) {
			if(hscript.exists(funcToCall)) 
				hscript.call(funcToCall, args);
			return;
		}
	}

	public function setOnScripts(variable:String, arg:Dynamic) {
		if(hscript != null) {
			hscript.set(variable, arg);
			return;
		}
	}

	function setUp_scripted() {
		hscript.set('detailsShow', detailsShow);
		hscript.set('controls', controls);
		hscript.set('state', instance);
		hscript.set('StateUtil', StateUtil);
		// functions
		hscript.set('fileExists', function(value:Dynamic) {
			return Paths.fileExists(value, TEXT);
		});

		hscript.set('getObject', function(value:Array<Any>) {
			return FlxG.random.getObject(value);
		});

		hscript.set('loadSong', function(name:String, curDifficulty:Int = -1){
			var songLowercase:String = Paths.formatToSongPath(name);
			var _song:String = Highscore.formatSong(songLowercase, curDifficulty);
			Song.loadFromJson(_song, songLowercase);

			try{
				Song.loadFromJson(_song, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
			}catch(e:haxe.Exception){
				trace('ERROR! ${e.message}'.red());
				return;
			}

			FlxG.camera.filters = [];
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
		});

		hscript.set('loadWeek', function(songArray:Array<String>, curDifficulty:Int = -1){
			try {
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
		
				var diffic = Difficulty.getFilePath(curDifficulty);
				if(diffic == null) diffic = '';
		
				PlayState.storyDifficulty = curDifficulty;
		
				Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			} catch(e:Dynamic) {
				trace('ERROR! $e');
				return;
			}
				
			var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory) 
				Paths.freeGraphicsFromMemory();
				
			LoadingState.prepareToSong();

			LoadingState.loadAndSwitchState(new PlayState(), true);
			FreeplayState.destroyFreeplayVocals();
				
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		});
	}
}