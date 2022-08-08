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

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
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
		var iconPath = char;
		var path = Paths.image('$iconPath/icon', 'assets', 'characters');
		var iconExists = FileSystem.exists(Paths.getPath('characters/$iconPath/icon.png', IMAGE));

		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

		if (!iconExists)
		{
			if (iconPath != trimmedCharacter)
				path = Paths.image('$trimmedCharacter/icon', 'assets', 'characters');
			else
				path = Paths.image('credits/face');
			trace('$char icon is invalid, trying $trimmedCharacter instead you fuck');
		}

		antialiasing = (!char.endsWith('-pixel'));

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

		/**
		* ANIMATED ICONS, HARDCODED
		* FOR TESTING PURPOSES AS OF NOW, I DON'T KNOW IF I'M ACTUALLY ADDING THEM FR!!!
		**/
		if (char == 'hypno2plus')
		{
			frames = Paths.getSparrowAtlas('icon', 'assets', 'characters/$iconPath');

			animation.addByPrefix('static', '$iconPath-static', 24, true);
			animation.addByPrefix('losing', '$iconPath-losing', 24, true);
			animation.addByPrefix('winning', '$iconPath-winning', 24, true);
		}

		initialWidth = width;
		initialHeight = height;

		animation.play('static');
		scrollFactor.set();
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
