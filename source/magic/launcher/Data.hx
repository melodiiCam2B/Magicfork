package magic.launcher;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import states.TitleState;

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables {
	public var loadedLauncher:Bool = false;
    public var launcherVersion:String = '1.0';
    public var executableVersion:String = '1.0';
}

class Data {
	public static var data:SaveVariables = {};

	public static function saveSettings() {
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		FlxG.save.flush();
	}

	public static function loadPrefs() {
		for (key in Reflect.fields(data))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
		
	}
}
