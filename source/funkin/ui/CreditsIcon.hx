package funkin.ui;

import sys.FileSystem;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

/*
	a copy of HealthIcon
 */
class CreditsIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public var icon:String;

	public function new(icon:String)
	{
		super();
		updateIcon(icon);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	var bounceTween:FlxTween;

	public function bop(time:Float)
	{
		scale.set(1.2, 1.2);
		if (bounceTween != null)
			bounceTween.cancel();
		bounceTween = FlxTween.tween(this.scale, {x: 1, y: 1}, time / base.Conductor.playbackRate, {ease: FlxEase.expoOut});
	}

	public function updateIcon(char:String, isPlayer:Bool = false)
	{
		if (!FileSystem.exists(Paths.getPath('images/credits/$char.png', IMAGE)))
			visible = false;

		var iconGraphic:FlxGraphic = Paths.image('credits/$char');

		loadGraphic(iconGraphic);
		antialiasing = (!Init.getSetting('Disable Antialiasing'));
		updateHitbox();

		initialWidth = width;
		initialHeight = height;

		animation.add('icon', [0], 0, false, isPlayer);
		animation.play('icon');
		scrollFactor.set();
	}
}
