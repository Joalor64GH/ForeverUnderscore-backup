package funkin;

import base.Conductor;
import base.ForeverAssets;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import funkin.Timings;
import states.PlayState;

using StringTools;

class UIStaticArrow extends FlxSprite
{
	/*  Oh hey, just gonna port this code from the previous Skater engine 
		(depending on the release of this you might not have it cus I might rewrite skater to use this engine instead)
		It's basically just code from the game itself but
		it's in a separate class and I also added the ability to set offsets for the arrows.

		uh hey you're cute ;)
	 */
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var babyArrowType:Int = 0;
	public var canFinishAnimation:Bool = true;

	public static var swagWidth:Float = 160 * 0.7;

	public var initialX:Int;
	public var initialY:Int;

	public var xTo:Float;
	public var yTo:Float;
	public var angleTo:Float;

	public var setAlpha:Float = (Init.trueSettings.get('Opaque Arrows')) ? 1 : 0.8;

	public var resetAnim:Float = 0;

	public function new(x:Float, y:Float, ?babyArrowType:Int = 0)
	{
		// this extension is just going to rely a lot on preexisting code as I wanna try to write an extension before I do options and stuff
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();

		this.babyArrowType = babyArrowType;

		updateHitbox();
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (resetAnim > 0)
		{
			resetAnim -= elapsed;

			if (resetAnim <= 0.0975) // little detail.
				playAnim('pressed');
			if (resetAnim < 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}
	}

	// literally just character code
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName == 'confirm')
			alpha = 1;
		else
			alpha = setAlpha;

		animation.play(AnimName, Force, Reversed, Frame);
		updateHitbox();

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	public static function getArrowFromNumber(numb:Int)
	{
		// yeah no I'm not writing the same shit 4 times over
		// take it or leave it my guy
		var stringSect:String = '';
		switch (numb)
		{
			case(0):
				stringSect = 'left';
			case(1):
				stringSect = 'down';
			case(2):
				stringSect = 'up';
			case(3):
				stringSect = 'right';
		}
		return stringSect;
		//
	}

	// that last function was so useful I gave it a sequel
	public static function getColorFromNumber(numb:Int)
	{
		var stringSect:String = '';
		switch (numb)
		{
			case(0):
				stringSect = 'purple';
			case(1):
				stringSect = 'blue';
			case(2):
				stringSect = 'green';
			case(3):
				stringSect = 'red';
		}
		return stringSect;
	}
}

class Strumline extends FlxSpriteGroup
{
	public var receptors:FlxTypedSpriteGroup<UIStaticArrow>;
	public var splashNotes:FlxTypedSpriteGroup<NoteSplash>;
	public var notesGroup:FlxTypedSpriteGroup<Note>;
	public var holdsGroup:FlxTypedSpriteGroup<Note>;
	public var allNotes:FlxTypedSpriteGroup<Note>;

	public var autoplay:Bool = true;
	public var character:Character;
	public var playState:PlayState;
	public var displayJudgements:Bool = false;

	public function new(xPos:Float = 0, yPos:Float = 0, playState:PlayState, ?character:Character, ?displayJudgements:Bool = true, ?autoplay:Bool = true,
			?noteSplashes:Bool = false, ?keyAmount:Int = 4, ?parent:Strumline)
	{
		super();

		this.autoplay = autoplay;
		this.character = character;
		this.playState = playState;
		this.displayJudgements = displayJudgements;

		receptors = new FlxTypedSpriteGroup<UIStaticArrow>();
		splashNotes = new FlxTypedSpriteGroup<NoteSplash>();
		notesGroup = new FlxTypedSpriteGroup<Note>();
		holdsGroup = new FlxTypedSpriteGroup<Note>();
		allNotes = new FlxTypedSpriteGroup<Note>();

		for (i in 0...keyAmount)
		{
			var receptor:UIStaticArrow = ForeverAssets.generateUIArrows(-25 + xPos, 25 + yPos, i, PlayState.assetModifier);
			receptor.ID = i;

			receptor.x -= ((keyAmount / 2) * UIStaticArrow.swagWidth);
			receptor.x += (UIStaticArrow.swagWidth * i);
			receptors.add(receptor);

			receptor.initialX = Math.floor(receptor.x);
			receptor.initialY = Math.floor(receptor.y);
			receptor.angleTo = 0;
			receptor.y -= 10;
			receptor.playAnim('static');

			receptor.alpha = 0;
			FlxTween.tween(receptor, {y: receptor.initialY, alpha: receptor.setAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			if (noteSplashes)
			{
				var noteSplash:NoteSplash = ForeverAssets.generateNoteSplashes('noteSplashes', PlayState.assetModifier, PlayState.changeableSkin, 'UI', i);
				splashNotes.add(noteSplash);
			}
		}

		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'stepmania')
			add(holdsGroup);
		add(receptors);
		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'fnf')
			add(holdsGroup);
		add(notesGroup);
		if (splashNotes != null)
			add(splashNotes);
	}

	public function createSplash(coolNote:Note)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	public function push(newNote:Note)
	{
		var chosenGroup = (newNote.isSustainNote ? holdsGroup : notesGroup);
		chosenGroup.add(newNote);
		allNotes.add(newNote);
		chosenGroup.sort(FlxSort.byY, (!Init.trueSettings.get('Downscroll')) ? FlxSort.DESCENDING : FlxSort.ASCENDING);
	}
}
