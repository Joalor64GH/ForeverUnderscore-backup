package funkin;

import dependency.FNFSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import states.PlayState;

using StringTools;

/**
 * Class for Handling Rating, Combo and Timing Sprites;
 * will be used for more stuff later;
 * WIP;
 */
class Rating extends FNFSprite
{
	public var daRating:String;

	public function new(daRating:String)
	{
		super(x, y);

		this.daRating = daRating;

		screenCenter();

		x = (FlxG.width * 0.55) - 40;
		y -= 60;
		if (!Init.trueSettings.get('Simply Judgements'))
		{
			acceleration.y = 550;
			velocity.y = -FlxG.random.int(140, 175);
			velocity.x = -FlxG.random.int(0, 10);
		}
		// x += Init.comboPosition[0][0];
		// y -= Init.comboPosition[0][1];
	}
}

class Timing extends FNFSprite
{
	public var hitTiming:String;
	public var daRating:String;

	public function new(hitTiming:String, ?daRating:String)
	{
		super(x, y);

		this.hitTiming = hitTiming;
		this.daRating = daRating;

		// positions should be here;
	}
}

class Combo extends FNFSprite
{
	public var scoreInt:Int;

	public function new(scoreInt:Int)
	{
		super(x, y);

		this.scoreInt = scoreInt;

		screenCenter();
		updateHitbox();
		alpha = 1;

		x += (43 * scoreInt) + 20;
		y += 60;
		if (!Init.trueSettings.get('Simply Judgements'))
		{
			acceleration.y = FlxG.random.int(200, 300);
			velocity.y = -FlxG.random.int(140, 160);
			velocity.x = FlxG.random.float(-5, 5);
		}
		// x += Init.comboPosition[1][0];
		// y -= Init.comboPosition[1][1];
	}
}