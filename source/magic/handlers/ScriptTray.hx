package magic.handlers;

class ScriptTray extends FlxSoundTray {
	private var hscript:HScript = null;
	var volumeMaxSound:String;
	
	public function new() {
		super();
		removeChildren();
		
		var scriptPath:String = Mods.checkForStates(Paths.getSharedPath(), 'data/scripts/SoundTray.hx');
		if(FileSystem.exists(scriptPath)) {
			try {
				hscript = new HScript(null, scriptPath);
				if(hscript != null) setUp_scripted();
				callOnScripts('createTray', [globalVolume]);
			}catch(e:IrisError) {
				var pos:HScriptInfos = cast {fileName: scriptPath, showLine: false};
				Iris.error(Printer.errorToString(e, false), pos);
			}
		}
	}
	
	override public function update(MS:Float):Void {
		callOnScripts('updateTray', [MS, globalVolume]);
	}
	
	override public function show(up:Bool = false):Void {
		callOnScripts('showTray', [up, globalVolume]);
		if (!silent) {
			var sound = up ? volumeUpSound : volumeDownSound;
			if (globalVolume == 10) sound = volumeMaxSound;
			if (sound != null) FlxG.sound.play(Paths.sound(sound));
		}
		saveData();
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
		hscript.set('volumeUpSound', volumeUpSound);
		hscript.set('volumeDownSound', volumeDownSound);
		hscript.set('volumeMaxSound', volumeMaxSound);
		
		// functions
		hscript.set('checkAntialiasing', function() {
			checkAntialiasing();
		});
		hscript.set('saveData', function() {
			saveData();
		});
		hscript.set('getBitmapData', function(path:String, useCache:Bool = true) {
			getBitmapData();
		});
	}

	public static function checkAntialiasing() {
		if (cast(__children[0], Bitmap).smoothing != ClientPrefs.data.antialiasing) 
			for (child in __children) 
				cast(child, Bitmap).smoothing = ClientPrefs.data.antialiasing;
	}

	public static function saveData() {
		if (FlxG.save.isBound) {
			FlxG.save.data.mute = FlxG.sound.muted;
			FlxG.save.data.volume = FlxG.sound.volume;
			FlxG.save.flush();
		}
	}

	public static function getBitmapData(path:String, useCache:Bool = true):Null<BitmapData> {
		var bitmap:Null<BitmapData> = null;
		if (FileSystem.exists(path)) bitmap = BitmapData.fromFile(path);
		if (Assets.exists(path, IMAGE)) bitmap = Assets.getBitmapData(path, useCache);
		
		return bitmap;
	}
}