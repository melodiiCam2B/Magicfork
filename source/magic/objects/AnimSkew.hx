package magic.objects;

import animate.FlxAnimateController.FlxAnimateAnimation;
import animate.FlxAnimateFrames.FlxAnimateSettings;
import animate.internal.FilterRenderer;
import animate.internal.Frame;
import animate.internal.StageBG;
import animate.internal.Timeline;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxAngle;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

using flixel.util.FlxColorTransformUtil;

#if !flash
import animate.internal.RenderTexture;
#end
#if FLX_DEBUG
import flixel.FlxBasic;
#end

class AnimSkew extends SkewSpr {
	public static var drawDebugLimbs:Bool = false;
	public var skew(default, null):FlxPoint;
	public var anim(default, set):FlxAnimateController = null;
	public var library(default, null):FlxAnimateFrames;
	public var isAnimate(default, null):Bool = false;
	public var timeline(default, null):Timeline;
	public var applyStageMatrix(default, set):Bool = false;
	public var renderStage:Bool = false;
	public var useRenderTexture:Bool = false;

	#if !flash
	var _renderTexture:RenderTexture;
	#end
	var _renderTextureDirty:Bool = true;

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset, ?settings:FlxAnimateSettings) {
		var loadedAnimateAtlas:Bool = false;
		if (simpleGraphic != null && simpleGraphic is String) {
			if (Path.extension(simpleGraphic).length == 0)
				loadedAnimateAtlas = true;
		}

		super(x, y, loadedAnimateAtlas ? null : simpleGraphic);

		if (loadedAnimateAtlas)
			frames = FlxAnimateFrames.fromAnimate(simpleGraphic, null, null, null, false, settings);
	}

	    /**
     * [Description]
     * @param graph graphic
     * @param list per array [name, [anim_name], [indices]]
     */
    function atlas(graph:String, list:Array<Array<Dynamic>>){
        frames = Get.atlas(graph);
        for (i => anim in list)
            anim.addBySymbolIndices(anim[0], anim[1],  anim[2]);
    }

    /**
     * [Description]
     * @param graph graphic
     * @param list per array [name, [anim_name], fps, should loop]
     */
    function sheet(graph:String, list:Array<Array<Dynamic>>) {
        frames = Get.sheet(graph);
        for (i => anim in list)
            animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
    }

    /**
     * [Description]
     * @param graph graphic
     * @param fw frame width
     * @param fh frame height
     * @param list per array [name, [indices], fps, should loop]
     */
    function graphic(graph:String, fw:Int, fh:Int, list:Array<Array<Dynamic>>){
        loadGraphic(Get.image(graph), true, fw, fh);
        for (i => anim in list)
            animation.add(anim[0], anim[1], anim[2], anim[3]);
    }

	override function initVars() {
		super.initVars();
		anim = new FlxAnimateController(this);
		skew = new FlxPoint();
		animation = anim;
	}

	override function set_frames(frames:FlxFramesCollection):FlxFramesCollection {
		isAnimate = (frames != null) && (frames is FlxAnimateFrames);

		var resultFrames = super.set_frames(frames);

		if (isAnimate) {
			library = cast frames;
			timeline = library.timeline;
			applyStageMatrix = this.applyStageMatrix;
			resetHelpers();
		} else {
			library = null;
			timeline = null;
		}

		return resultFrames;
	}

	override function draw():Void {
		if (!isAnimate) {
			super.draw();
			return;
		}

		if (alpha <= 0.0 || Math.abs(scale.x) <= 0.0 || Math.abs(scale.y) <= 0.0)
			return;

		for (camera in #if (flixel >= "5.7.0") this.getCamerasLegacy() #else this.cameras #end) {
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			drawAnimate(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	function checkRenderTexture():Bool {
		#if flash
		return false;
		#else
		return isAnimate && useRenderTexture && (alpha != 1 || shader != null || (blend != null && blend != NORMAL));
		#end
	}

	function drawAnimate(camera:FlxCamera):Void {
		final willUseRenderTexture = checkRenderTexture();
		final matrix = _matrix;
		matrix.identity();

		@:privateAccess
		var bounds = timeline._bounds;
		if (!willUseRenderTexture)
			matrix.translate(-bounds.x, -bounds.y);

		prepareAnimateMatrix(matrix, camera, bounds);

		if (renderStage)
			drawStage(camera);

		timeline.currentFrame = animation.frameIndex;

		#if !flash
		if (willUseRenderTexture) {
			if (_renderTexture == null)
				_renderTexture = new RenderTexture(Math.ceil(bounds.width), Math.ceil(bounds.height));

			if (_renderTextureDirty) {
				_renderTexture.init(Math.ceil(bounds.width), Math.ceil(bounds.height));
				_renderTexture.drawToCamera((camera, matrix) ->
				{
					matrix.translate(-bounds.x, -bounds.y);
					timeline.draw(camera, matrix, null, null, antialiasing, null);
				});
				_renderTexture.render();

				_renderTextureDirty = false;
			}

			camera.drawPixels(_renderTexture.graphic.imageFrame.frame, framePixels, matrix, colorTransform, blend, antialiasing, shader);
		}
		else
		#end
		{
			timeline.draw(camera, matrix, colorTransform, blend, antialiasing, shader);
		}
	}

	function prepareAnimateMatrix(matrix:FlxMatrix, camera:FlxCamera, bounds:FlxRect):Void {
		if (checkFlipX()) {
			matrix.scale(-1, 1);
			matrix.translate(bounds.width, 0);
		}

		if (checkFlipY()) {
			matrix.scale(1, -1);
			matrix.translate(0, bounds.height);
		}

		prepareDrawMatrix(matrix, camera);
	}

	// I dont think theres a way to override the matrix without needing to do this lol
	#if (flixel >= "6.1.0")
	override function drawFrameComplex(frame:FlxFrame, camera:FlxCamera):Void
	#else
	override function drawComplex(camera:FlxCamera):Void
	#end
	{
		#if (flixel < "6.1.0") final frame = this._frame; #end
		final matrix = this._matrix; // TODO: Just use local?

		frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		prepareDrawMatrix(matrix, camera);
		camera.drawPixels(frame, framePixels, matrix, colorTransform, blend, antialiasing, shader);
	}

	function prepareDrawMatrix(matrix:FlxMatrix, camera:FlxCamera):Void {
		final doStageMatrix:Bool = (isAnimate && applyStageMatrix);

		if (doStageMatrix)
			matrix.translate(timeline._bounds.x, timeline._bounds.y);
		

		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);

		if (angle != 0) {
			updateTrig();
			matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		if (skew.x != 0 || skew.y != 0) {
			updateSkew();
			matrix.concat(_skewMatrix);
		}

		if (doStageMatrix) // TODO: add some way to customize the order of this thing
			matrix.concat(library.matrix);

		getScreenPosition(_point, camera);
		_point.x += origin.x - offset.x;
		_point.y += origin.y - offset.y;
		matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
			preparePixelPerfectMatrix(matrix);
	}

	function preparePixelPerfectMatrix(matrix:FlxMatrix):Void
	{
		matrix.tx = Math.floor(matrix.tx);
		matrix.ty = Math.floor(matrix.ty);
	}

	var stageBg:StageBG;

	function drawStage(camera:FlxCamera):Void {
		if (stageBg == null)
			stageBg = new StageBG();

		stageBg.render(this, camera);
	}

	// semi stolen from FlxSkewedSprite
	static var _skewMatrix:FlxMatrix = new FlxMatrix();

	private inline function updateSkew():Void {
		_skewMatrix.setTo(1, Math.tan(skew.y * FlxAngle.TO_RAD), Math.tan(skew.x * FlxAngle.TO_RAD), 1, 0, 0);
	}

	private inline function set_applyStageMatrix(v:Bool):Bool {
		this.applyStageMatrix = v;

		// Like resetFrame() but for animate
		if (this.isAnimate)
			anim.updateTimelineBounds();

		return v;
	}

	#if (flixel >= "5.4.0")
	override function get_numFrames():Int {
		if (!isAnimate)
			return super.get_numFrames();

		@:privateAccess
		{
			if (animation._curAnim != null)
				return cast(animation._curAnim, FlxAnimateAnimation).timeline.frameCount;
		}

		return 0;
	}
	#end

	private function set_anim(newController:FlxAnimateController):FlxAnimateController {
		anim = newController;
		animation = anim;
		return newController;
	}

	override function updateFramePixels():BitmapData {
		if (!isAnimate)
			return super.updateFramePixels();

		if (timeline == null || !dirty)
			return framePixels;

		if (framePixels != null) {
			framePixels.dispose();
			framePixels.disposeImage();
		}

		@:privateAccess
		{
			final bounds = timeline._bounds;
			final flipX = checkFlipX();
			final flipY = checkFlipY();
			final mat = #if flash new Matrix() #else Matrix.__pool.get() #end;

			#if flash
			framePixels = FilterRenderer.getBitmap((cam, m) -> {
				m.concat(mat);
				timeline.draw(cam, m, null, NORMAL, true, null);
			}, bounds, false);
			#else
			framePixels = FilterRenderer.renderToBitmap((camera:FlxCamera, matrix:FlxMatrix) -> {
				Frame.__isDirtyCall = false;
				matrix.translate(-bounds.x, -bounds.y);
				matrix.concat(mat);

				camera.width = Math.ceil(bounds.width);
				camera.height = Math.ceil(bounds.height);

				timeline.currentFrame = animation.frameIndex;
				timeline.draw(camera, matrix, null, NORMAL, true, null);
				camera.render();

				if (camera.canvas.graphics.__bounds != null)
					camera.canvas.graphics.__bounds.setTo(0, 0, Math.ceil(bounds.width), Math.ceil(bounds.height));
			});
			Matrix.__pool.release(mat);
			#end
		}

		dirty = false;
		return framePixels;
	}

	#if (flixel >= "5.0.0")
	override function getScreenBounds(?rect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (rect == null)
			rect = FlxRect.get();

		if (camera == null)
			camera = #if (flixel >= "6.0.0") getDefaultCamera() #else FlxG.camera #end;

		rect.set(0.0, 0.0, frameWidth, frameHeight);

		final matrix = this._matrix;
		matrix.identity();

		isAnimate ? prepareAnimateMatrix(matrix, camera, timeline._bounds) : prepareDrawMatrix(matrix, camera);

		if (isAnimate && renderStage) {
			var stageRect = library.stageRect;
			rect.x = -timeline._bounds.x - (stageRect.width * 0.5);
			rect.y = -timeline._bounds.y - (stageRect.height * 0.5);
			rect.width = Math.max(rect.width, stageRect.width);
			rect.height = Math.max(rect.height, stageRect.height);
		}

		Timeline.applyMatrixToRect(rect, matrix);

		return rect;
	}
	#end

	function getAnimateOrigin(?result:FlxPoint):FlxPoint {
		result ??= FlxPoint.get();
		result.set();

		if (isAnimate && applyStageMatrix) {
			var matrix = library.matrix;
			result.add(matrix.tx, matrix.ty);
			result.add(timeline._bounds.x * matrix.a, timeline._bounds.y * matrix.d);
		}

		return result;
	}

	override function destroy():Void {
		super.destroy();
		#if !flash
		_renderTexture = FlxDestroyUtil.destroy(_renderTexture);
		#end
		anim = FlxDestroyUtil.destroy(anim);
		library = null;
		timeline = null;
		stageBg = FlxDestroyUtil.destroy(stageBg);
		skew = FlxDestroyUtil.put(skew);
	}
}