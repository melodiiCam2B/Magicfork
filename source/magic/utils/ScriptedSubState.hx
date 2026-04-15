package source.magic.utils;

class ScriptedSubState extends MusicBeatSubstate{
	private var hscript:HScript;
	private var stateName:String;
    public static var finishCallback:Void->Void;
	private var state_id:String
    public function new(name:String):Void{
		/**
		 * ! failsafe 
		 * coded this so that custom states are possible
		 */
		state_id = name;
		stateName = Mods.modStates.exists(name)? Mods.modStates.get(name) : name;
		super();

		print('${Type.getClass(FlxG.state)} as $stateName'.blue());
	}

    override function create() {
		super.create();

		if(Mods.currentModDirectory != null && Mods.currentModDirectory.trim().length > 0) {
			var scriptPath:String = 'mods/${Mods.currentModDirectory}/data/substates/${stateName}.hx';
			if(FileSystem.exists(scriptPath)) {
				try {
					hscript = new HScript(null, scriptPath);
					callOnScripts('onCreate');
				} catch(e:IrisError) {
					var pos:HScriptInfos = cast {fileName: scriptPath, showLine: false};
					Iris.error(Printer.errorToString(e, false), pos);
					var hscript:HScript = cast (Iris.instances.get(scriptPath), HScript);
				}
                setUp_scripted();
			}else{
				print('$scriptName script [$scriptName] not found.');
			}
		}
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
	
    public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null):Dynamic {
		if(hscript != null) {
			if(hscript.exists(funcToCall)) hscript.call(funcToCall, args);
			return;
		}
	}

	public function setOnScripts(variable:String, arg:Dynamic) {
		if(hscript != null) {
			hscript.set(funcToCall, args);
			return;
		}
	}

	function setUp_scripted() {
        hscript.set('close', close());
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