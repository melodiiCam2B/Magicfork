package;

#if android
import android.content.Context;
#end

import debug.FPSCounter;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.TitleState;

#if (linux || mac)
import lime.graphics.Image;
#end

#if desktop
import backend.ALSoftConfig; // Just to make sure DCE doesn't remove this, since it's not directly referenced anywhere else.
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

import backend.Highscore;

// NATIVE API STUFF, YOU CAN IGNORE THIS AND SCROLL //
#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite
{
	// thread runnning, not supper important but does somewhat optimize things
	public static function run(func:Void->Void, ?onException:Exception->Void) {
		sys.thread.Thread.create(() -> {
			try {
				func();
			} catch (exc) {
				if (onException != null) onException(exc);
				else throw exc;
			}
		});
	}

	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: magic.Intro, // initial game state
		framerate: 60, // default framerate
		skipSplash: false, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var persist:StateUtil;

	public static function main():Void {
		Lib.current.addChild(new Main());
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
	}

	public static var fpsVar:DisplayDebug;

	public function new() {
		super();
		initHaxeUI();

		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		// should work, not 100% sure but we ball lowk
		// magic.launcher.Data.loadPrefs();

		// if(!magic.launcher.Data.data.loadedLauncher)
		// 	launcher();
		// else 
			executable();
	}

	public function launcher() {
		// second game for launcher)
		var launching = new MagicSpoon(1280, 720, magic.launcher.State, 60, 60, true, false);
		addChild(launching);
	}

	public function executable() {
		backend.Native.fixScaling();
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		setupDebug();
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		Achievements.load();
		TraceUtil.setup();

		var app = new MagicSpoon(game.width, game.height, game.initialState, game.framerate, game.framerate, true, game.startFullscreen);
		// @:privateAccess
		// app._customSoundTray = magic.handlers.SoundTray;
		addChild(app);
		
		addChild(fpsVar = new DisplayDebug());
		persist = new StateUtil();

		// @:privateAccess
		// var mouseSprite = FlxG.mouse.cursorContainer; 
		// if (mouseSprite != null)
		// 	Lib.current.stage.addChild(mouseSprite);

		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		DiscordClient.prepare();

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		    if (FlxG.cameras != null) 
			   	for (cam in FlxG.cameras.list) 
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);
			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});

		loadPlugins();
	}
	public static function loadPlugins() {
		FlxG.plugins.addPlugin(new PluginReload());
		// FlxG.plugins.addPlugin(fpsVar = new PluginDebug(false));
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	function initHaxeUI():Void {
		#if haxeui_core
		haxe.ui.Toolkit.init();
		haxe.ui.Toolkit.theme = 'dark';
		haxe.ui.Toolkit.autoScale = false;
		haxe.ui.focus.FocusManager.instance.autoFocus = false;
		haxe.ui.tooltips.ToolTipManager.defaultDelay = 200;
		#end
	}

	function setupDebug():Void {
		#if HSCRIPT_ALLOWED
		Iris.warn = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(WARN, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(ERROR, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(FATAL, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);
		}
		#end

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
	}
}
