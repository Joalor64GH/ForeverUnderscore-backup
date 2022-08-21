package base;

import base.*;
import dependency.FNFSprite;
import flixel.*;
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
	}

	override public function preset():Void
	{
		super.preset();

		interp.variables.set('FlxG', FlxG);
		interp.variables.set('FlxBasic', FlxBasic);
		interp.variables.set('FlxObject', FlxObject);
		interp.variables.set('FlxCamera', FlxCamera);
		interp.variables.set('FlxSprite', FlxSprite);
		interp.variables.set('FlxTimer', FlxTimer);
		interp.variables.set('FlxTween', FlxTween);
		interp.variables.set('FlxEase', FlxEase);
		interp.variables.set('FlxMath', FlxMath);
		interp.variables.set('FlxSound', FlxSound);
	}
}

class ScriptFuncs extends PlayState
{
	public static function callBaseVars()
	{
		PlayState.contents.setVar('fnfVer', Application.current.meta.get('version'));
		PlayState.contents.setVar('foreverVer', Main.foreverVersion);
		PlayState.contents.setVar('underscoreVer', Main.underscoreVersion);

		// Timings.hx values
		PlayState.contents.setVar('comboRating', Timings.comboDisplay);
		PlayState.contents.setVar('accuracy', Math.floor(Timings.getAccuracy() * 100) / 100);
		PlayState.contents.setVar('rank', Timings.returnScoreRating().toUpperCase());

		PlayState.contents.setVar('Paths', Paths);
		PlayState.contents.setVar('Controls', Controls);
		PlayState.contents.setVar('PlayState', PlayState);
		PlayState.contents.setVar('Note', Note);
		PlayState.contents.setVar('Strumline', Strumline);
		PlayState.contents.setVar('Timings', Timings);
		PlayState.contents.setVar('Conductor', Conductor);

		PlayState.contents.setVar('makeGraphic',
			function(spriteID:String, graphicCol:Dynamic, x:Int = 0, y:Int = 0, scrollX:Float = null, scrollY:Float = null, alpha:Float = 1, size:Float = 1)
			{
				var sprite = new FNFSprite(x, y);
				sprite.makeGraphic(x, y, graphicCol);
				sprite.scrollFactor.set(scrollX, scrollY);
				sprite.setGraphicSize(Std.int(sprite.width * size));
				sprite.alpha = alpha;
				sprite.antialiasing = true;
				PlayState.GraphicMap.set(spriteID, sprite);
				PlayState.contents.setVar('$spriteID', sprite);
				PlayState.contents.add(sprite);
			});

		PlayState.contents.setVar('loadGraphic',
			function(spriteID:String, key:String, x:Int = 0, y:Int = 0, scrollX:Float = null, scrollY:Float = null, alpha:Float = 1, size:Float = 1,
					scaleX:Float = 1, scaleY:Float = 1)
			{
				var sprite = new FNFSprite(x, y);
				sprite.loadGraphic(Paths.image(key));
				sprite.scrollFactor.set(scrollX, scrollY);
				sprite.setGraphicSize(Std.int(sprite.width * size));
				sprite.alpha = alpha;
				sprite.scale.set(scaleX, scaleY);
				sprite.antialiasing = true;
				PlayState.GraphicMap.set(spriteID, sprite);
				PlayState.contents.setVar('$spriteID', sprite);
				PlayState.contents.add(sprite);
			});

		PlayState.contents.setVar('loadAnimatedGraphic',
			function(spriteID:String, key:String, path:String = null, spriteType:String, anims:Array<Array<Dynamic>>, defaultAnim:String, x:Float = 0,
					y:Float = 0, scrollX:Float = 0, scrollY:Float = 0, alpha:Float = 1, size:Float = 1, scaleX:Float = 1, scaleY:Float = 1)
			{
				var sprite:FNFSprite = new FNFSprite(x, y);

				switch (spriteType)
				{
					case "packer":
						sprite.frames = Paths.getPackerAtlas(key, path);
					case "sparrow":
						sprite.frames = Paths.getSparrowAtlas(key, path);
					case "sparrow-hash":
						sprite.frames = Paths.getSparrowHashAtlas(key, path);
				}

				for (anim in anims)
				{
					sprite.animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
				}

				sprite.setGraphicSize(Std.int(sprite.width * size));
				sprite.scrollFactor.set(scrollX, scrollY);
				sprite.updateHitbox();
				sprite.animation.play(defaultAnim);
				sprite.antialiasing = true;
				sprite.alpha = alpha;
				sprite.scale.set(scaleX, scaleY);
				PlayState.GraphicMap.set(spriteID, sprite);
				PlayState.contents.setVar('$spriteID', sprite);
				PlayState.contents.add(sprite);
			});

		PlayState.contents.setVar('createCharacter', function(charID:String, key:String, x:Float, y:Float, alpha:Float, isPlayer:Bool = false)
		{
			var newChar:Character;
			newChar = new Character(x, y, isPlayer, key);
			newChar.alpha = alpha;
			newChar.dance();
			PlayState.contents.characterArray.push(newChar);
			PlayState.contents.setVar('$charID', charID);
			PlayState.contents.add(newChar);
		});

		PlayState.contents.setVar('changeCharacter', function(key:String, target:String, x:Float, y:Float)
		{
			PlayState.contents.changeCharacter(key, target, x, y);
		});

		PlayState.contents.setVar('castShader', function(shaderID:String, key:String, camera:String = 'camGame', startEnabled:Bool = true)
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
					PlayState.ShaderMap.set(shaderID, shader);

					switch (camera)
					{
						case 'camhud' | 'camHUD' | 'hud' | 'ui':
							PlayState.camHUD.setFilters([new ShaderFilter(shader)]);
						case 'camgame' | 'camGame' | 'game' | 'world':
							PlayState.camGame.setFilters([new ShaderFilter(shader)]);
						case 'strumhud' | 'strumHUD' | 'strum' | 'strumlines':
							for (lines in 0...PlayState.strumHUD.length)
								PlayState.strumHUD[lines].setFilters([new ShaderFilter(shader)]);
					}

					if (!startEnabled)
						FlxG.camera.filtersEnabled = false;
				}
				else
				{
					return;
				}
			}
		});

		PlayState.contents.setVar('trace', function(text:String, printOnHud:Bool = true, color:Array<Int> = null)
		{
			if (color == null)
				color = [255, 255, 255];

			trace(text);

			if (printOnHud)
			{
				PlayState.uiHUD.traceBar.text += '$text\n';
				PlayState.uiHUD.traceBar.color = FlxColor.fromRGB(color[0], color[1], color[2]);
				FlxTween.tween(PlayState.uiHUD.traceBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

				new FlxTimer().start(6, function(tmr:FlxTimer)
				{
					FlxTween.tween(PlayState.uiHUD.traceBar, {alpha: 0}, 0.5, {ease: FlxEase.circOut});
				});
			}
		});

		PlayState.contents.setVar('playSound', function(sound:String)
		{
			FlxG.sound.play(Paths.sound(sound));
		});

		PlayState.contents.setVar('getSetting', function(key:String)
		{
			Init.trueSettings.get(key);
		});

		PlayState.contents.setVar('setSetting', function(key:String, value:Dynamic)
		{
			Init.trueSettings.set(key, value);
		});

		PlayState.contents.setVar('getColor', function(color:String)
		{
			ForeverTools.getColorFromString(color);
		});

		PlayState.contents.setVar('doTweenX', function(tweenID:String, object:Dynamic, value:Float, time:Float, ease:String)
		{
			var leTween:FlxTween;
			
			leTween = FlxTween.tween(object, {x: value}, time, {
				ease: ForeverTools.getEaseFromString(ease),
				onComplete: function(tween:FlxTween)
				{
					PlayState.contents.completeTween(tweenID);
					leTween = null;
				}
			});
		});

		PlayState.contents.setVar('doTweenY', function(tweenID:String, object:Dynamic, value:Float, time:Float, ease:String)
		{
			var leTween:FlxTween;

			leTween = FlxTween.tween(object, {y: value}, time, {
				ease: ForeverTools.getEaseFromString(ease),
				onComplete: function(tween:FlxTween)
				{
					PlayState.contents.completeTween(tweenID);
					leTween = null;
				}
			});
		});

		PlayState.contents.setVar('doTweenAlpha', function(tweenID:String, object:Dynamic, value:Float, time:Float, ease:String)
		{
			var leTween:FlxTween;

			leTween = FlxTween.tween(object, {alpha: value}, time, {
				ease: ForeverTools.getEaseFromString(ease),
				onComplete: function(tween:FlxTween)
				{
					PlayState.contents.completeTween(tweenID);
					leTween = null;
				}
			});
		});

		PlayState.contents.setVar('doTweenAngle', function(tweenID:String, object:Dynamic, value:Float, time:Float, ease:String)
		{
			var leTween:FlxTween;

			leTween = FlxTween.tween(object, {angle: value}, time, {
				ease: ForeverTools.getEaseFromString(ease),
				onComplete: function(tween:FlxTween)
				{
					PlayState.contents.completeTween(tweenID);
					leTween = null;
				}
			});
		});

		PlayState.contents.setVar('doTweenDirection', function(tweenID:String, object:Dynamic, value:Float, time:Float, ease:String)
		{
			var leTween:FlxTween;

			leTween = FlxTween.tween(object, {direction: value}, time, {
				ease: ForeverTools.getEaseFromString(ease),
				onComplete: function(tween:FlxTween)
				{
					PlayState.contents.completeTween(tweenID);
					leTween = null;
				}
			});
		});

		PlayState.contents.setVar('doTweenZoom', function(tweenID:String, object:Dynamic, value:Float, time:Float, ease:String)
		{
			var leTween:FlxTween;

			leTween = FlxTween.tween(object, {zoom: value}, time, {
				ease: ForeverTools.getEaseFromString(ease),
				onComplete: function(tween:FlxTween)
				{
					PlayState.contents.completeTween(tweenID);
					leTween = null;
				}
			});
		});
	}
}