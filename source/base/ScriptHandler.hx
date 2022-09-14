package base;

import base.*;
import dependency.*;
import flixel.*;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.*;
import flixel.system.*;
import flixel.tweens.*;
import flixel.util.*;
import funkin.*;
import lime.app.Application;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import states.PlayState;
import sys.io.File;

class ScriptHandler extends SScript
{
	public function new(file:String, ?preset:Bool = true)
	{
		super(file, preset);
		traces = false;
	}

	override public function preset():Void
	{
		super.preset();

		set('FlxG', FlxG);
		set('FlxBasic', FlxBasic);
		set('FlxObject', FlxObject);
		set('FlxCamera', FlxCamera);
		set('FlxSprite', FlxSprite);
		set('FlxSound', FlxSound);
		set('FlxTimer', FlxTimer);
		set('FlxTween', FlxTween);
		set('FlxEase', FlxEase);
		set('FlxMath', FlxMath);
		set('FlxSound', FlxSound);
		set('FlxGroup', FlxGroup);
		set('FlxTypedGroup', FlxTypedGroup);
		set('FlxSpriteGroup', FlxSpriteGroup);
		set('FlxStringUtil', FlxStringUtil);
		set('FlxAtlasFrames', FlxAtlasFrames);
		set('FlxSort', FlxSort);
		set('Application', Application);
		set('FlxGraphic', FlxGraphic);
		set('FlxAtlasFrames', FlxAtlasFrames);
		set('File', File);
		set('FlxTrail', FlxTrail);

		// CLASSES (FOREVER);
		set('Init', Init);
		set('ForeverAssets', ForeverAssets);
		set('ForeverTools', ForeverTools);
		set('FNFSprite', FNFSprite);
		set('Discord', Discord);

		// CLASSES (BASE);
		set('Alphabet', Alphabet);
		set('Character', Character);
		set('Controls', Controls);
		set('CoolUtil', CoolUtil);
		set('Conductor', Conductor);
		set('PlayState', PlayState);
		set('Main', Main);
		set('Note', Note);
		set('Strumline', Strumline);
		set('Paths', Paths);
		set('Stage', Stage);
		set('Timings', Timings);
	}
}

class ScriptFuncs extends PlayState
{
	public static function setBaseVars()
	{
		PlayState.contents.setVar('castShader', function(shaderID:String, key:String, camera:String = 'camGame')
		{
			if (Init.trueSettings.get('Disable Shaders'))
			{
				return null;
			}
			else
			{
				if (key != null || key != '')
				{
					var shader:GraphicsShader = new GraphicsShader("", File.getContent(Paths.shader(key)));
					PlayState.ScriptedShaders.set(shaderID, shader);

					switch (camera)
					{
						case 'camhud' | 'camHUD' | 'hud' | 'ui':
							PlayState.camHUD.setFilters([new ShaderFilter(shader)]);
						case 'camgame' | 'camGame' | 'game' | 'world':
							PlayState.camGame.setFilters([new ShaderFilter(shader)]);
						case 'strumhud' | 'strumHUD' | 'strum' | 'strumlines':
							PlayState.strumHUD.setFilters([new ShaderFilter(shader)]);
					}
				}
				else
				{
					return;
				}
			}
		});
	}
}