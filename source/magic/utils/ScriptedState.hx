package magic.utils;

class ScriptedState extends MusicBeatState {
	private var hscript:HScript;
	private var stateName:String;
    public function new(name:String):Void{
		/**
		 * ! failsafe 
		 * coded this so that custom states are possible
		 */
		stateName = Mods.modStates.exists(name)? Mods.modStates.get(name) : name;
		super();

		print('${Type.getClass(FlxG.state)} as $stateName'.blue());
	}

    override function create() {
        persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        super.create();

		if(Mods.currentModDirectory != null && Mods.currentModDirectory.trim().length > 0) {
			var scriptPath:String = 'mods/${Mods.currentModDirectory}/data/states/${stateName}.hx';
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

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		#if ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

        var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Magicfork v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("genshin.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
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