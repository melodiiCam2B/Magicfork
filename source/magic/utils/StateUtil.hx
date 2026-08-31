package magic.utils;

import haxe.macro.Expr;
import haxe.macro.Context;

import openfl.utils.Assets;

import haxe.Json;
import haxe.DynamicAccess;

typedef ScriptStates = {
	var ?main:String;
	var ?title:String;
	var ?story:String;
	var ?credits:String;
	var ?startup:String;
	var ?freeplay:String;

	var ?pause:String;
	var ?transition:String;
	var ?gameover:String;

	var ?optionsmain:String;
	var ?optionsgraphics:String;
	var ?optionskeybinds:String;
	var ?optionsnotecolor:String;
	var ?optionsgameplay:String;
	var ?optionslanguage:String;
	var ?optionsvisual:String;
};

class StateUtil {
    
    static public var currentDirr:String = '';
    static public var instance:ScriptedState;
	static public var subinstance:ScriptedSubState;
	static public var modStates:Map<String, String>;

	public var scripts:Map<String, Dynamic>;

	public function new() {
		scripts = [];
	}

	// we're specifically requesting Main's StateUtil instance to insure we always get the same one!
	inline public static function getValue( s:String )
		return Main.persist.scripts.get( instance.stateName+':'+s );
	
	inline public static function setValue(s:String, v:Dynamic) 
		return Main.persist.scripts.set(instance.stateName+':'+s, v );
	
	inline public static function isValue( s:String) 
		return Main.persist.scripts.exists( instance.stateName+':'+s );

	// global incase you want a specific variable from a script state
	inline public static function getGlobal( f:String, s:String )
		return Main.persist.scripts.get( f+':'+s );
	
	inline public static function setGlobal( f:String, s:String, v:Dynamic ) 
		return Main.persist.scripts.set( f+':'+s, v);
	
	inline public static function isGlobal( f:String, s:String) 
		return Main.persist.scripts.exists( f+':'+s );
	
	// boring state shit
	static public var defaultStates:Map<String, String> = [
		'title' => 'TitleState',
		'main' => 'MainMenu',
		'story' => 'StoryMode',
		'freeplay' => 'FreePlay',
		'credits' => 'CreditState',
		'startup' => 'StartUp',

		'pause' => 'PauseState',
		'transition' => 'TransitionState',
		'gameover' => 'GameOverState',

		// options can be added and removed as wanted!
        'optionsmain' => 'Options',
        'optionsgraphics' =>  'options/Graphics',
        'optionskeybinds' =>  'options/Keybinds',
        'optionsnotecolor' =>  'options/Notecolor',
        'optionsgameplay' =>  'options/Gameplay',
        'optionslanguage' =>  'options/Language',
        'optionsvisual' =>  'options/Visual'
	];

	public static function loadTopSate() {
		currentDirr = '';
		modStates = defaultStates; 
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			currentDirr = list[0];

		var path:String = checkForStates(Paths.getSharedPath(), 'data/states.json');
		if(FileSystem.exists(path)) {
			var rawData:ScriptStates = Json.parse(path.getText());
			for (field in Reflect.fields(rawData)) 
				modStates.set(field, Reflect.field(rawData, field));
		}
	}

    inline public static function checkForStates(path:String, fileToFind:String, mods:Bool = true){
		// this should failsave to the shared folder if the loaded mod doesn't have the current state
		var file:String = '$path$fileToFind'; 
		//Main folder
		if(FileSystem.exists(path + fileToFind))
			file = path + fileToFind;

		// Week folder
		if(Paths.currentLevel != null && Paths.currentLevel != path) {
			var pth:String = Paths.getFolderPath(fileToFind, Paths.currentLevel);
			if(FileSystem.exists(pth))
				file = pth;
		}

		if(mods) {
			// Global mods first
			for(mod in Mods.getGlobalMods()) {
				var folder:String = Paths.mods(mod + '/' + fileToFind);
				if(FileSystem.exists(folder)) file = folder;
			}

			// Then "PsychEngine/mods/" main folder
			var folder:String = Paths.mods(fileToFind);
			if(FileSystem.exists(folder)) file = folder;

			// And lastly, the loaded mod's folder
			if(currentDirr != null && currentDirr.length > 0) {
				var folder:String = Paths.mods(currentDirr + '/' + fileToFind);
				if(FileSystem.exists(folder)) file = folder;
			}
		}
		trace('Path is: $path$fileToFind => $file'.magenta());
		return file;
	}

    inline public static function findFile(path:String, fileToFind:String, mods:Bool = true, ?newPath:String){
		var file:String = null;
		
		newPath = haxe.io.Path.join([Sys.getCwd(), fileToFind]);
		if(FileSystem.exists(newPath) && file == null)
			file = path + fileToFind;

		if(FileSystem.exists(path + fileToFind) && file == null)
			file = path + fileToFind;

		if(Paths.currentLevel != null && Paths.currentLevel != path && file == null) {
			var pth:String = Paths.getFolderPath(fileToFind, Paths.currentLevel);
			if(FileSystem.exists(pth))
				file = pth;
		}

		if(mods) {
			if(file == null){
				for(mod in Mods.getGlobalMods()) {
					var folder:String = Paths.mods(mod + '/' + fileToFind);
					if(FileSystem.exists(folder)) file = folder;
				}
			}

			if(file == null) {
				var folder:String = Paths.mods(fileToFind);
				if(FileSystem.exists(folder)) file = folder;
			}

			if(currentDirr != null && currentDirr.length > 0 && file == null) {
				var folder:String = Paths.mods(currentDirr + '/' + fileToFind);
				if(FileSystem.exists(folder)) file = folder;
			}
		}
		return file;
	}

	// parses var name along with data
	// unused, but I'm keeping it here for funzies
    #if macro
    public static macro function setTo(value:Expr) 
        persist.set('${instance.state_id}:' + parseName(value), value);
    
    public static macro function getFrom(value:Expr) 
        return value = persist.get('${instance.state_id}:' + parseName(value));

    public static macro function checkFor(value:Expr)
        return value = persist.exists('${instance.state_id}:' + parseName(value));
    
	
	static function parseName(e:Expr):Expr {
		return switch (e.expr) {
			case EConst(CIdent(s)): macro $v{s};
			case _: Context.error("Expected an identifier", e.pos);
		}
	}
	#end
}