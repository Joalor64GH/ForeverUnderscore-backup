package funkin;

import sys.FileSystem;
import base.*;
import dependency.FNFSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.OverlayShader;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.system.scaleModes.*;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.display.BlendMode;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import states.PlayState;
import funkin.background.*;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	//
	public var gfVersion:String = 'gf';

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;
	public var layers:FlxTypedGroup<FlxBasic>;

	public var spawnGirlfriend:Bool = true;

	public var stageScript:ScriptHandler;

	public function new(curStage:String = 'unknown', stageDebug:Bool = false)
	{
		super();
		this.curStage = curStage;

		if (curStage == null || curStage.length < 1)
		{
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				case 'bopeebo' | 'fresh' | 'dadbattle' | 'dad-battle':
					curStage = 'stage';
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'philly-nice' | 'philly' | 'blammed':
					curStage = 'philly';
				case 'satin-panties' | 'high' | 'milf':
					curStage = 'highway';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'military';
				default:
					curStage = 'unknown';
			}
		}
		if (!stageDebug)
			PlayState.curStage = PlayState.SONG.stage;

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();
		layers = new FlxTypedGroup<FlxBasic>();

		//
		switch (curStage)
		{
			default:
				curStage = 'unknown';
				PlayState.defaultCamZoom = 0.9;
		}

		callStageScript();
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		switch (curStage)
		{
			case 'highway':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school' | 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'military':
				if (PlayState.SONG.song.toLowerCase() == 'stress')
					gfVersion = 'pico-speaker';
				else
					gfVersion = 'gf-tankmen';
			default:
				gfVersion = 'gf';
		}

		return gfVersion;
	}

	public function dadPosition(curStage:String, boyfriend:Character, gf:Character, dad:Character, camPos:FlxPoint):Void
	{
		callFunc('dadPosition', [boyfriend, gf, dad, camPos]);
	}

	public function repositionPlayers(curStage:String, boyfriend:Character, gf:Character, dad:Character)
	{
		callFunc('repositionPlayers', [boyfriend, gf, dad]);
	}

	public function stageUpdate(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
	{
		callFunc('updateStage', [curBeat, boyfriend, gf, dad]);
	}

	public function stageUpdateSteps(curStep:Int, boyfriend:Character, gf:Character, dad:Character)
	{
		callFunc('updateStageSteps', [curStep, boyfriend, gf, dad]);
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Character, gf:Character, dad:Character)
	{
		callFunc('updateStageConst', [elapsed, boyfriend, gf, dad]);
	}

	override public function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	function callStageScript()
	{
		var paths:Array<String> = [
			Paths.getPreloadPath('stages/$curStage/$curStage.hx'),
			Paths.getPreloadPath('stages/$curStage/$curStage.hxs')
		];

		for (path in paths)
		{
        	if (FileSystem.exists(path))
            	stageScript = new ScriptHandler(path);
		}

		setVar('add', add);
		setVar('foreground', foreground);
		setVar('layers', layers);
		setVar('gfVersion', gfVersion);
		setVar('game', PlayState.contents);
		setVar('spawnGirlfriend', function(blah:Bool)
		{
			spawnGirlfriend = blah;
		});
		setVar('BackgroundDancer', BackgroundDancer);
		setVar('BackgroundGirls', BackgroundGirls);
		setVar('TankmenBG', TankmenBG);

		callFunc('generateStage', []);
	}

	public function callFunc(key:String, args:Array<Dynamic>)
	{
		if (stageScript == null)
            return null;
		else
			return stageScript.call(key, args);
	}

	public function setVar(key:String, value:Dynamic)
	{
        if (stageScript == null)
            return null;
		else
			return stageScript.set(key, value);
	}
}
