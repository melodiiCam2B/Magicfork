package magic.utils;

import flixel.addons.transition.FlxTransitionableState;

class PluginReload extends FlxBasic {
	public function new() {
		super();
		this.visible = false;
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.F5) {
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
	}
}