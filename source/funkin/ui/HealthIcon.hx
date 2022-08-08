package funkin.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public var char = 'bf';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	// dynamic, to avoid having 31 billion if statements;
	public dynamic function updateAnim(health:Float)
	{
		if (health < 20)
			animation.play('losing');
		else if (health > 85)
			animation.play('winning');
		else
			animation.play('static');
	}

	public function updateIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var path = Paths.image('$char/icon', 'assets', 'characters');
		var iconExists = FileSystem.exists(Paths.getPath('characters/$char/icon.png', IMAGE));

		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

		if (!iconExists)
		{
			if (char != trimmedCharacter)
				path = Paths.image('$trimmedCharacter/icon', 'assets', 'characters');
			else
				path = Paths.image('credits/face');
			trace('$char icon is invalid, trying $trimmedCharacter instead you fuck');
		}

		switch (char)
		{
			case 'hypno2plus':
				/**
				 * ANIMATED ICONS, HARDCODED
				 * FOR TESTING PURPOSES AS OF NOW, I DON'T KNOW IF I'M ACTUALLY ADDING THEM FR!!!
				**/
				frames = Paths.getSparrowAtlas('icon', 'assets', 'characters/$char');

				animation.addByPrefix('static', '$char-static', 24, true, isPlayer);
				animation.addByPrefix('losing', '$char-losing', 24, true, isPlayer);
				animation.addByPrefix('winning', '$char-winning', 24, true, isPlayer);
			default:
				var iconGraphic:FlxGraphic = path;
				var iconWidth = 1;

				switch (iconGraphic.width)
				{
					case 450: iconWidth = 3;
					case 300: iconWidth = 2;
					case 150: iconWidth = 1;
				}

				loadGraphic(iconGraphic);
				loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / iconWidth), iconGraphic.height);

				animation.add('static', [0], 0, false, isPlayer);
				animation.add('losing', [1], 0, false, isPlayer);

				// ternary to avoid frame 1 playing where it shouldn't
				animation.add('winning', (iconWidth == 3 ? [2] : [0]), 0, false, isPlayer);
				scrollFactor.set();
		}
		animation.play('static');
		updateHitbox();

		initialWidth = width;
		initialHeight = height;

		antialiasing = (!char.endsWith('-pixel'));
	}
}
