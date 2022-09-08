package base;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

using StringTools;

class ControlsFormatter
{
	public static function formatKeyName(key:FlxKey):String
	{
		switch (key)
		{
			case BACKSPACE: return "BCKSPC";
			case CONTROL: return "CTRL";
			case ALT: return "ALT";
			case CAPSLOCK: return "CAPS";
			case PAGEUP: return "PGUP";
			case PAGEDOWN: return "PGDOWN";
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
			case NUMPADZERO: return "#0";
			case NUMPADONE: return "#1";
			case NUMPADTWO: return "#2";
			case NUMPADTHREE: return "#3";
			case NUMPADFOUR: return "#4";
			case NUMPADFIVE: return "#5";
			case NUMPADSIX: return "#6";
			case NUMPADSEVEN: return "#7";
			case NUMPADEIGHT: return "#8";
			case NUMPADNINE: return "#9";
			case NUMPADMULTIPLY: return "#*";
			case NUMPADPLUS: return "#+";
			case NUMPADMINUS: return "#-";
			case NUMPADPERIOD: return "#.";
			case SEMICOLON: return ";";
			case COMMA: return ",";
			case PERIOD: return ".";
			case SLASH: return "/";
			case GRAVEACCENT: return "`";
			case LBRACKET: return "[";
			case BACKSLASH: return "\\";
			case RBRACKET: return "]";
			case QUOTE: return "'";
			case PRINTSCREEN: return "PRTSCRN";
			case NONE: return '---';
			default:
				var label:String = '' + key;
				if (label.toLowerCase() == 'null')
					return '---';
				return '' + label.charAt(0).toUpperCase() + label.substr(1).toUpperCase();
		}
	}
}