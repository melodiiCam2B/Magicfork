package magic.handlers;

import magic.handlers.Handler.Mode;
import haxe.ui.backend.flixel.CursorHelper;
import lime.app.Future;
import openfl.display.BitmapData;

typedef Data =
{
  graphic:String,
  scale:Float,
  offsetX:Int,
  offsetY:Int,
}

class Texture {
    static var assetMap:Map<Mode, Null<BitmapData>> = [];
// assets/images/cursor/
    public static final DEFAULT:Data = { graphic: "cursor-default.png", scale: 1.0, offsetX: 0, offsetY: 0 };
    public static final CROSS:Data = { graphic: "cursor-cross.png", scale: 1.0, offsetX: 0, offsetY: 0 };
    public static final ERASER:Data = { graphic: "cursor-eraser.png", scale: 1.0, offsetX: 0, offsetY: 0 };
    public static final GRABBING:Data = { graphic: "cursor-grabbing.png", scale: 1.0, offsetX: -8, offsetY: 0 };
    public static final THROBBER:Data = { graphic: "cursor-hourglass.png", scale: 1.0, offsetX: 0, offsetY: 0 };
    public static final POINTER:Data = { graphic: "cursor-pointer.png", scale: 1.0, offsetX: -8, offsetY: 0 };
    public static final TEXT:Data = { graphic: "cursor-text.png", scale: 0.2, offsetX: 0, offsetY: 0 };
    public static final TEXT_VERTICAL:Data = { graphic: "cursor-text-vertical.png", scale: 0.2, offsetX: 0, offsetY: 0 };
    public static final ZOOM_IN:Data = { graphic: "cursor-zoom-in.png", scale: 1.0, offsetX: 0, offsetY: 0 };
    public static final ZOOM_OUT:Data = { graphic: "cursor-zoom-out.png", scale: 1.0, offsetX: 0, offsetY: 0 };
    public static final CROSSHAIR:Data = { graphic: "cursor-crosshair.png", scale: 1.0, offsetX: -16, offsetY: -16 };
    public static final CELL:Data = { graphic: "cursor-cell.png", scale: 1.0, offsetX: -16, offsetY: -16 };
    public static final SCROLL:Data = { graphic: "cursor-scroll.png", scale: 0.2, offsetX: -15, offsetY: -15 };

    static var paramMap:Map<Mode, Data> = [
        Default => DEFAULT, 
        Cross => CROSS, 
        Eraser => ERASER, 
        Grabbing => GRABBING, 
        Throbber => THROBBER, 
        Text => TEXT, 
        TextVertical => TEXT_VERTICAL, 
        Pointer => POINTER,  
        Scroll => SCROLL, 
        Crosshair => CROSSHAIR, 
        Cell => CELL,
        ZoomOut => ZOOM_OUT, 
        ZoomIn => ZOOM_IN
    ];

    public static function param(value:Mode)
        return paramMap.get(value);
    
    static function set(?value:Mode = null):Void {
        if (value == null) {
            FlxG.mouse.unload();
            return;
        }

        if (assetMap.exists(value))
            var bitmapData:BitmapData = assetMap.get(value);
        else 
            var bitmapData:BitmapData = Assets.getBitmapData('assets/images/cursor/' + param(value).graphic);

        if(!assetMap.exists(value)) 
            assetMap.set(value, bitmapData);

        applyData(bitmapData, value);
    }

    static inline function applyData(graphic:BitmapData, value:Data):Void
        FlxG.mouse.load(graphic, param(value).scale, param(value).offsetX, param(value).offsetY);

}