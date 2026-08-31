package magic.handlers;

class SoundTray extends FlxSoundTray {
	var graphicScale:Float = 0.30;
	var lerpYPos:Float = 0;
	var alphaTarget:Float = 0;
	
	var volumeMaxSound:String;
	
	public function new() {
		super();
		removeChildren();
		
		var bg:Bitmap = new Bitmap(getBitmapData(Paths.getPath('soundtray/volumebox.png', IMAGE, 'image')));
		bg.scaleX = graphicScale;
		bg.scaleY = graphicScale;
		bg.smoothing = ClientPrefs.data.antialiasing;
		addChild(bg);
		
		y = -height;
		visible = false;
	
		var backingBar:Bitmap = new Bitmap(getBitmapData(Paths.getPath('soundtray/bars_10.png', IMAGE, 'image')));
		backingBar.x = 9;
		backingBar.y = 5;
		backingBar.scaleX = graphicScale;
		backingBar.scaleY = graphicScale;
		backingBar.smoothing = ClientPrefs.data.antialiasing;
		addChild(backingBar);
		backingBar.alpha = 0.4;
		
		_bars = [];

		for (i in 1...11)
		{
			var bar:Bitmap = new Bitmap(getBitmapData(Paths.getPath('soundtray/bars_$i.png', IMAGE, 'image')));
			bar.x = 9;
			bar.y = 5;
			bar.scaleX = graphicScale;
			bar.scaleY = graphicScale;
			bar.smoothing = ClientPrefs.data.antialiasing;
			addChild(bar);
			_bars.push(bar);
		}
		
		y = -height;
		screenCenter();
		
		volumeUpSound = 'soundtray/Volup';
		volumeDownSound = 'soundtray/Voldown';
		volumeMaxSound = 'soundtray/VolMAX';
	}
	
	override public function update(MS:Float):Void
	{
		y = MathUtil.fpsLerp(y, lerpYPos, 0.1);
		alpha = MathUtil.fpsLerp(alpha, alphaTarget, 0.25);
		
		if (_timer > 0) {
			_timer -= (MS / 1000);
			alphaTarget = 1;
		} else if (y >= -height) {
			lerpYPos = -height - 10;
			alphaTarget = 0;
		}
		
		if (y <= -height) {
			visible = false;
			active = false;
			
			#if FLX_SAVE
	
			if (FlxG.save.isBound) {
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
			#end
		}
	}
	
	function checkAntialiasing() {
		if (cast(__children[0], Bitmap).smoothing != ClientPrefs.data.antialiasing) {
			for (child in __children) {
				cast(child, Bitmap).smoothing = ClientPrefs.data.antialiasing;
			}
		}
	}
	
	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	up Whether the volume is increasing.
	 */
	override public function show(up:Bool = false):Void {
		showFunkinBar(up);
	}
	
	function showFunkinBar(up:Bool = false) {
		_timer = 1;
		lerpYPos = 10;
		visible = true;
		active = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
		
		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}
		
		if (!silent)
		{
			var sound = up ? volumeUpSound : volumeDownSound;
			
			if (globalVolume == 10) sound = volumeMaxSound;
			
			if (sound != null) FlxG.sound.play(Paths.sound(sound));
		}
		
		for (i in 0..._bars.length)
			_bars[i].visible = i < globalVolume;
			
		checkAntialiasing();
	}
	#if (flixel > "6.0.0")
	override function showAnim(volume:Float, ?sound:FlxSoundAsset, duration:Float = 1.0, label:String = "VOLUME") {}
	
	override function updateSize() {}
	
	override function showIncrement() {
		showFunkinBar(true);
	}
	
	override function showDecrement() {
		showFunkinBar(false);
	}
	#end

	public static function getBitmapData(path:String, useCache:Bool = true):Null<BitmapData> {
		var bitmap:Null<BitmapData> = null;
		if (FileSystem.exists(path)) bitmap = BitmapData.fromFile(path);
		if (Assets.exists(path, IMAGE)) bitmap = Assets.getBitmapData(path, useCache);
		
		return bitmap;
	}
}