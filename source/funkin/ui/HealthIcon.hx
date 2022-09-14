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

	public var icon = 'bf';

	public function new(icon:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(icon, isPlayer);
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
		if (health < 20 && animation.getByName('losing') != null)
			animation.play('losing');
		else if (health > 85 && animation.getByName('winning') != null)
			animation.play('winning');
		else
			animation.play('static');
	}

	public function updateIcon(icon:String = 'bf', isPlayer:Bool = false)
	{
		var path = Paths.image('$icon/icon', 'characters');
		var iconExists = FileSystem.exists(Paths.getPath('characters/$icon/icon.png', IMAGE));

		var trimmedIcon:String = icon;
		if (trimmedIcon.contains('-'))
			trimmedIcon = trimmedIcon.substring(0, trimmedIcon.indexOf('-'));

		if (!iconExists)
		{
			if (icon != trimmedIcon)
				path = Paths.image('$trimmedIcon/icon', 'characters');
			else
				path = Paths.image('characters/face');
			//trace('$icon icon is invalid, trying $trimmedIcon instead you fuck');
		}

		var iconGraphic:FlxGraphic = path;
		var iconWidth = 1;

		iconWidth = Std.int(iconGraphic.width / 150) - 1;
		iconWidth = iconWidth + 1;

		loadGraphic(iconGraphic);
		loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / iconWidth), iconGraphic.height);

		animation.add('static', [0], 0, false, isPlayer);
		animation.add('losing', [1], 0, false, isPlayer);
		animation.add('winning', [2], 0, false, isPlayer);
		animation.play('static');
		scrollFactor.set();
		updateHitbox();

		initialWidth = width;
		initialHeight = height;

		antialiasing = (!icon.endsWith('-pixel') || !Init.trueSettings.get('Disable Antialiasing'));
	}
}
