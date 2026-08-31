package magic.utils;

class ScriptedSubState extends MusicBeatSubstate{
	private var hscript:HScript;
	private var stateName:String;
    public static var finishCallback:Void->Void;
	private var state_id:String;
	public static var instance:ScriptedSubState;
    public function new(name:String):Void{
		state_id = name;
		stateName = StateUtil.modStates.exists(name)? StateUtil.modStates.get(name) : name;
		super();
		instance = this;
		StateUtil.subinstance = instance;
		print('${Type.getClass(FlxG.state)} as $stateName'.blue());
	}

    override function create() {
		super.create();

		var scriptPath:String = StateUtil.checkForStates(Paths.getSharedPath(), 'data/states/${stateName}.hx');
		if(FileSystem.exists(scriptPath)) {
			try {
				hscript = new HScript(null, scriptPath);
			} catch(e:IrisError) {
				var pos:HScriptInfos = cast {fileName: scriptPath, showLine: false};
				Iris.error(Printer.errorToString(e, false), pos);
				var hscript:HScript = cast (Iris.instances.get(scriptPath), HScript);
			}
		}else{
			print('$stateName script [ $scriptPath ] not found.'.blue());
			close();
		}

		if(hscript != null) {
			setUp_scripted();
			callOnScripts('onCreate');
			callOnScripts('create');
		}

		print('${Type.getClass(FlxG.state)} as $stateName [${Date.now().toString()}]'.blue());

		
	}

    override function close():Void {
		super.close();

		if(finishCallback != null) {
			finishCallback();
			finishCallback = null;
		}
	}

    override function update(elapsed:Float) {
		super.update(elapsed);
        callOnScripts('onUpdate', [elapsed]);
	}

	override function stepHit():Void {
		super.stepHit();

        setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	override function beatHit():Void {
		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}
	
    public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null) {
		if(hscript != null) {
			if(hscript.exists(funcToCall)) hscript.call(funcToCall, args);
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
		hscript.set('controls', controls);
		hscript.set('state', instance);
		hscript.set('StateUtil', StateUtil);
		// functions
        hscript.set('close', function(){
			close();
		});

		hscript.set('LoadSong', function(name:String, curDifficulty:Int = -1){
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