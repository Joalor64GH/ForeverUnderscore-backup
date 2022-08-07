package funkin.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
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
			animation.play('idle');
	}

	public function updateIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var icon = char;
		var path = Paths.image('$icon/icon', 'assets', 'characters');
		var iconExists = FileSystem.exists(Paths.getPath('characters/$icon/icon.png', IMAGE));

		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

		if (!iconExists)
		{
			if (icon != trimmedCharacter)
				path = Paths.image('$trimmedCharacter/icon', 'assets', 'characters');
			else
				path = Paths.image('credits/face');
			trace('$char icon is invalid, trying $trimmedCharacter instead you fuck');
		}

		antialiasing = true;
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

		animation.add('idle', [0], 0, false, isPlayer);
		animation.add('losing', [1], 0, false, isPlayer);

		// ternary to avoid frame 1 playing where it shouldn't
		animation.add('winning', (iconWidth == 3 ? [2] : [0]), 0, false, isPlayer);
		
		initialWidth = width;
		initialHeight = height;

		animation.play('idle');
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
