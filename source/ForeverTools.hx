package;

import sys.FileSystem;
import base.*;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import states.PlayState;

using StringTools;

/**
	This class is used as an extension to many other forever engine stuffs, please don't delete it as it is not only exclusively used in forever engine
	custom stuffs, and is instead used globally.
**/
class ForeverTools
{
	public static var mustUpdate:Bool = false;
	public static var updateVersion:String = '';

	// set up maps and stuffs
	public static function resetMenuMusic(resetVolume:Bool = false)
	{
		// make sure the music is playing
		if (((FlxG.sound.music != null) && (!FlxG.sound.music.playing)) || (FlxG.sound.music == null))
		{
			var menuSong:String = 'freakyMenu';
			menuSong = Init.trueSettings.get('Menu Song');

			var song = Paths.music('menus/$menuSong/$menuSong');
			FlxG.sound.playMusic(song, (resetVolume) ? 0 : 0.7);
			if (resetVolume)
				FlxG.sound.music.fadeIn(4, 0, 0.7);

			if (FlxG.sound.music.pitch != 1)
				FlxG.sound.music.pitch = 1;
			Conductor.changeBPM(102);
		}
	}

	/**
	 * [Returns a skin asset with the given parameters]
	 * @param asset the asset we should get from the asset skin folders
	 * @param assetModifier the asset modifier from the skin folders, usually `base`
	 * @param changeableSkin the changeable default skin for the asset we should get
	 * @param baseLibrary the base folder where we should grab the assets from, usually `UI`
	 * @param defaultChangeableSkin optional, specifies the default folder for the `changeableSkin` parameter
	 * @param defaultBaseAsset optional, specifies the default folder for the `assetModifier` parameter
	 * @return String, which references your custom Asset
	 */
	public static function returnSkin(asset:String, assetModifier:String = 'base', changeableSkin:String = 'default', baseLibrary:String,
			?defaultChangeableSkin:String = 'default', ?defaultBaseAsset:String = 'base'):String
	{
		var realAsset = '$baseLibrary/$changeableSkin/$assetModifier/$asset';
		if (!FileSystem.exists(Paths.getPath('images/' + realAsset + '.png', IMAGE)))
		{
			realAsset = '$baseLibrary/$defaultChangeableSkin/$assetModifier/$asset';
			if (!FileSystem.exists(Paths.getPath('images/' + realAsset + '.png', IMAGE)))
				realAsset = '$baseLibrary/$defaultChangeableSkin/$defaultBaseAsset/$asset';
		}

		return realAsset;
	}

	public static function killMusic(songsArray:Array<FlxSound>)
	{
		// neat function thing for songs
		for (i in 0...songsArray.length)
		{
			// stop
			songsArray[i].stop();
			songsArray[i].destroy();
		}
	}

	public static function checkUpdates()
	{
		// check for updates
		if (Init.trueSettings.get('Check for Updates'))
		{
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/BeastlyGhost/Forever-Engine-Underscore/master/gameVersion.txt");
			http.onData = function(data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = Main.underscoreVersion.trim();
				trace('Your Version: ' + curVersion + ' - Latest Version: ' + updateVersion);

				if (updateVersion != curVersion)
				{
					trace('version mismatch!');
					mustUpdate = true;
				}
			}
			http.onError = function(error)
			{
				trace('error: $error');
			}
			http.request();
		}
	}

	public static function returnCam(cam:String)
	{
		switch (cam)
		{
			case 'camgame' | 'camGame' | 'game' | 'world':
				return PlayState.camGame;
			case 'camhud' | 'camHUD' | 'hud' | 'ui':
				return PlayState.camHUD;
			case 'strumhud' | 'strumHUD' | 'strum' | 'strumlines':
				return PlayState.strumHUD;
		}
		return PlayState.camGame;
	}

	public static function returnTweenType(?type:String = ''):FlxTweenType
	{
		switch (type.toLowerCase())
		{
			case 'backward': return FlxTweenType.BACKWARD;
			case 'looping': return FlxTweenType.LOOPING;
			case 'oneshot': return FlxTweenType.ONESHOT;
			case 'persist': return FlxTweenType.PERSIST;
			case 'pingpong': return FlxTweenType.PINGPONG;
		}
		return FlxTweenType.PERSIST;
	}

	public static function returnBlendMode(str:String):BlendMode
	{
		return switch (str)
		{
			case "normal": BlendMode.NORMAL;
			case "darken": BlendMode.DARKEN;
			case "multiply": BlendMode.MULTIPLY;
			case "lighten": BlendMode.LIGHTEN;
			case "screen": BlendMode.SCREEN;
			case "overlay": BlendMode.OVERLAY;
			case "hardlight": BlendMode.HARDLIGHT;
			case "difference": BlendMode.DIFFERENCE;
			case "add": BlendMode.ADD;
			case "subtract": BlendMode.SUBTRACT;
			case "invert": BlendMode.INVERT;
			case _: BlendMode.NORMAL;
		}
	}

	public static function setTextAlign(str:String):FlxTextAlign
	{
		return switch (str)
		{
			case "center": FlxTextAlign.CENTER;
			case "justify": FlxTextAlign.JUSTIFY;
			case "left": FlxTextAlign.LEFT;
			case "right": FlxTextAlign.RIGHT;
			case _: FlxTextAlign.LEFT;
		}
	}

	public static function returnColor(?str:String = ''):FlxColor
	{
		switch (str.toLowerCase())
		{
			case "black": FlxColor.BLACK;
			case "white": FlxColor.WHITE;
			case "blue": FlxColor.BLUE;
			case "brown": FlxColor.BROWN;
			case "cyan": FlxColor.CYAN;
			case "gray": FlxColor.GRAY;
			case "green": FlxColor.GREEN;
			case "lime": FlxColor.LIME;
			case "magenta": FlxColor.MAGENTA;
			case "orange": FlxColor.ORANGE;
			case "pink": FlxColor.PINK;
			case "purple": FlxColor.PURPLE;
			case "red": FlxColor.RED;
			case "transparent": FlxColor.TRANSPARENT;
		}
		return FlxColor.TRANSPARENT;
	}

	public static function fromHSB(hue:Float, sat:Float, brt:Float, alpha:Float):FlxColor
	{
		return FlxColor.fromHSB(hue, sat, brt, alpha);
	}

	public static function fromRGB(red:Int, green:Int, blue:Int, alpha:Int):FlxColor
	{
		return FlxColor.fromRGB(red, green, blue, alpha);
	}

	public static function fromRGBFloat(red:Float, green:Float, blue:Float, alpha:Float):FlxColor
	{
		return FlxColor.fromRGBFloat(red, green, blue, alpha);
	}

	public static function fromInt(value:Int):FlxColor
	{
		return FlxColor.fromInt(value);
	}
	
	public static function fromString(str:String):FlxColor
	{
		return FlxColor.fromString(str);
	}
}
