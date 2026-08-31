#if !macro
//Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

import magic.*;
import magic.main.*;
import magic.utils.*;
import magic.menus.*;
import magic.hscript.*;
import magic.objects.*;
import magic.dialogue.*;

import backend.*;
import states.*;
import objects.*;
import substates.*;
import shaders.*;
import backend.animation.*;
import backend.ui.*;
import cutscenes.*;
import flxanimate.*;
// ui shit
import flixel.input.mouse.*;
import flixel.input.keyboard.*;

// polymod
import polymod.*;
import polymod.fs.*;
import polymod.util.*;
import polymod.format.*;
import polymod.hscript.*;
import polymod.util.zip.*;
import polymod.backends.*;

//Psych
import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;
import backend.Language;

import backend.ui.*; //Psych-UI
import objects.Alphabet;
import objects.BGSprite;
import states.PlayState;
import states.LoadingState;

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if HSCRIPT_ALLOWED
import psychlua.*;
import crowplexus.iris.*;
import crowplexus.iris.utils.*;
import psychlua.HScript.HScriptInfos;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end
import backend.Highscore;
import backend.Song;

import objects.MenuItem;
import objects.MenuCharacter;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import backend.StageData;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import states.editors.MasterEditorMenu;
import options.OptionsState;

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

// whatever the fuck
#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end
import flixel.FlxGame;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.app.Application;
import flixel.util.FlxTimer;
import openfl.Lib;
import openfl.Assets;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import haxe.io.Path;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
import haxe.Exception;
import haxe.Json;
import haxe.Http;
import haxe.zip.Entry;
import haxe.zip.Reader;
import haxe.crypto.Crc32;
import haxe.zip.Compress;
import haxe.zip.Tools;
import haxe.zip.Uncompress;
import haxe.zip.Writer;
import flixel.group.FlxSpriteGroup;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.textures.Texture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;
import flash.events.*;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.system.FlxSplash;
import flixel.util.typeLimit.NextState;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.*;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.Shape;
import flixel.group.*;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import sys.FileSystem;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display.Sprite;
import openfl.system.System;
import flixel.*;
import openfl.*;
import haxe.*;
import sys.*;
import lime.*;
import animate.*;
import Sys.sleep;
import sys.thread.Thread;
import lime.app.Application;
import hxdiscord_rpc.*;
import flixel.util.FlxStringUtil;
import sys.io.File;
import haxe.io.Path;

import openfl.Assets;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;

import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

import sys.thread.Deque;
import sys.thread.Thread;
import sys.thread.Mutex;

import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.ui.FlxBar;

import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

import flixel.system.ui.*;

import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;
using Reflect;
using Lambda;
using StringTools;
using magic.utils.Extensions;
#end
