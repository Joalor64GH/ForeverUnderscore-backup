package funkin;

import flixel.FlxG;
import dependency.FNFSprite;
import states.PlayState;

/**
 * Class for Hadling Rating Sprites;
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
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

/**
 * Class for Hadling Rating Timing Sprites;
 * WIP;
 */
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		super.playAnim(AnimName, Force, Reversed, Frame);
	}
}

class Combo extends FNFSprite
{}