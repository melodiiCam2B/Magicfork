package magic.utils;

class MathUtil {

	public static inline function fpsLerp(v1:Float, v2:Float, ratio:Float) 
		return lerp(v1, v2, getElapsedLerp(ratio, FlxG.elapsed));

	public static inline function lerp(a:Float, b:Float, ratio:Float):Float
		return a + ratio * (b - a);
	
	public static function getElapsedLerp(lerp:Float, elapsed:Float):Float
		return 1.0 - Math.pow(1.0 - lerp, elapsed * 60);
	
	public static function wrap(value:Float, min:Float, max:Float):Float {
		if (value < min) return max;
		else if (value > max) return min;
		else return value;
	}
	
	public static function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1) return Math.floor(value);
		
		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;
			
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static inline function numberArray(?min:Int, max:Int):Array<Int> {
		if (min == null) min = 0;
		return [for (i in min...max) i];
	}
	
	public static overload extern inline function clamp(input:Float, min:Float, max:Float):Float
		return bound(input, min, max);
	
	public static inline function bound(Value:Float, ?Min:Float, ?Max:Float):Float {
		var lowerBound:Float = (Min != null && Value < Min) ? Min : Value;
		return (Max != null && lowerBound > Max) ? Max : lowerBound;
	}
	
	public static overload extern inline function clamp(input:Int, min:Int, max:Int):Float {
		if (input < min) input = min;
		if (input > max) input = max;
		return input;
	}
}