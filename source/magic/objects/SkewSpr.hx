package magic.objects;
class SkewSpr extends FlxSprite {
	public var skew(default, null):FlxPoint = FlxPoint.get();
	public var transformMatrix(default, null):Matrix = new Matrix();
	public var matrixExposed:Bool = false;
	var _skewMatrix:Matrix = new Matrix();
	override public function destroy():Void {
		skew = FlxDestroyUtil.put(skew);
		_skewMatrix = null;
		transformMatrix = null;

		super.destroy();
	}

	override function drawComplex(camera:FlxCamera):Void {
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (matrixExposed) {
			_matrix.concat(transformMatrix);
		} else {
			if (bakedRotationAngle <= 0) {
				updateTrig();

				if (angle != 0)
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}

			updateSkewMatrix();
			_matrix.concat(_skewMatrix);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.addPoint(origin);
		if (isPixelPerfectRender(camera))
			_point.floor();

		_matrix.translate(_point.x, _point.y);
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	function updateSkewMatrix():Void {
		_skewMatrix.identity();

		if (skew.x != 0 || skew.y != 0)	{
			_skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
			_skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);
		}
	}

	override public function isSimpleRender(?camera:FlxCamera):Bool{
		if (FlxG.renderBlit)
			return super.isSimpleRender(camera) && (skew.x == 0) && (skew.y == 0) && !matrixExposed;
		else
			return false;
	}
}