package magic.utils;

class SaveUtil {
    public static var data:UtilVars = {};
	public static var defaultData:UtilVars = {};

    public static var util_:FlxSave;
    public static var save:FlxSave;
    public static function initSave(){
		util_ = new FlxSave();
		util_.bind('util', getSavePath());
        save = new FlxSave();
		save.bind('save', getSavePath());

        Application.current.window.onClose.add( function() { saveSettings(); });
	}

    // allows for new save fields
    public static function reflectData(to:Dynamic, from:Dynamic) {
        for (key in Reflect.fields(from))
			Reflect.setField(to, key, Reflect.field(from, key));
    }

    public static function saveSettings() {
		for (key in Reflect.fields(data))
			Reflect.setField(util_.data, key, Reflect.field(data, key));

		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		util_.flush();
		
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

    @:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';

	}
}

@:structInit class UtilVars {
	var tempSave:Bool = false;
}