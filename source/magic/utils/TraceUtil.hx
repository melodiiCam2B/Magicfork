package magic.utils;

class TraceUtil {
    public static function setup() 
        haxe.Log.trace = TraceUtil.trace;
    
    inline public static function trace(v:Dynamic, ?i:haxe.PosInfos):Void
        Sys.println(construct('', v, i));
    
    public static function construct(s:String, v:Dynamic, ?i:haxe.PosInfos):String 
        return '\033[0;33m[$s ${i.fileName}/${i.methodName}:${i.lineNumber}]\033[0m '+ v;
}