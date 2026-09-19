package magic.handlers;

import magic.handlers.Handler.Mode;
import magic.handlers.Texture.Data;
import haxe.ui.backend.flixel.CursorHelper;
import lime.app.Future;
import openfl.display.BitmapData;

enum Mode {
    Default;
    Pointer;
    Grabbing;
    Throbber;
    Crosshair;
    Cross;
    Eraser;
    Text;
    TextVertical;
    ZoomIn;
    ZoomOut;
    Cell;
    Scroll;
}

class Handler {
    public static var cursorMode(default, set):Null<Mode> = null;
    static function set_cursorMode(value:Null<Mode>):Null<Mode> {
        if (value != null && cursorMode != value)
            cursorMode = value;

        Texture.set(cursorMode);
        
        return cursorMode;
    }

    public static inline function show():Void {
        FlxG.mouse.visible = true;
        Cursor.cursorMode = Default;
    }

    public static inline function hide():Void {
        FlxG.mouse.visible = false;
        Cursor.cursorMode = null;
    }

    public static inline function toggle():Void {
        if (FlxG.mouse.visible)
            hide();
        else
            show();
    }

    public static function future(value:Data):Void {
        var future:Future<BitmapData> = Assets.loadBitmapData('assets/images/cursor/' + param.graphic);
        future.onComplete(function(bitmapData:BitmapData) { return bitmapData; });
    }
}