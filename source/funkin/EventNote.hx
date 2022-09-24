package funkin;

import dependency.AbsoluteText.EventText;
import flixel.FlxSprite;
import states.PlayState;

class EventNote extends FlxSprite
{
	public var event:String;
	public var strumTime:Float;
	public var val1:String;
	public var val2:String;
	public var child:EventText;

	public function new(event:String, strumTime:Float, val1:String, val2:String)
	{
		this.event = event;
		this.strumTime = strumTime;
		this.val1 = val1;
		this.val2 = val2;

		super();

		loadGraphic(Paths.image('menus/chart editor/eventNote-base'));
	}
}