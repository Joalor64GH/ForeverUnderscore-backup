package base;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

using StringTools;

/**
 * this is a class to format FlxKey outputs
 * it gets a key name and returns it as a string with the given return value
 * mainly used with `ControlsSubstate`;
 */

class KeyFormatter
{
	public static function formatKeyName(key:FlxKey):String
	{
		switch (key)
		{
			case BACKSPACE: return "BKSPC";
			case CONTROL: return "CTRL";
			case ALT: return "ALT";
			case CAPSLOCK: return "CAPS";
			case PAGEUP: return "PGUP";
			case PAGEDOWN: return "PGDOWN";
			case DELETE: return "DEL";
			case INSERT: return "INS";
			case PRINTSCREEN: return "PRINT";
			case ZERO: return "0";
			case ONE: return "1";
			case TWO: return "2";
			case THREE: return "3";
			case FOUR: return "4";
			case FIVE: return "5";
			case SIX: return "6";
			case SEVEN: return "7";
			case EIGHT: return "8";
			case NINE: return "9";
			case NUMPADZERO: return "KP0";
			case NUMPADONE: return "KP1";
			case NUMPADTWO: return "KP2";
			case NUMPADTHREE: return "KP3";
			case NUMPADFOUR: return "KP4";
			case NUMPADFIVE: return "KP5";
			case NUMPADSIX: return "KP6";
			case NUMPADSEVEN: return "KP7";
			case NUMPADEIGHT: return "KP8";
			case NUMPADNINE: return "KP9";
			case NUMPADMULTIPLY: return "KP*";
			case NUMPADPLUS: return "KP+";
			case NUMPADMINUS: return "KP-";
			case NUMPADPERIOD: return "KP.";
			case SEMICOLON: return ";";
			case COMMA: return ",";
			case PERIOD: return ".";
			case SLASH: return "/";
			case GRAVEACCENT: return "`";
			case LBRACKET: return "[";
			case BACKSLASH: return "\\";
			case RBRACKET: return "]";
			case QUOTE: return "'";
			case NONE: return 'none';
			default:
				var label:String = '' + key;
				if (label.toLowerCase() == 'null')
					return 'none';
				return '' + label.charAt(0).toUpperCase() + label.substr(1).toUpperCase();
		}
	}
}