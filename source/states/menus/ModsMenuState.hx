package states.menus;

import sys.FileSystem;
import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.Alphabet;

using StringTools;

class ModsMenuState extends MusicBeatState
{
	var alphaGroup:FlxTypedGroup<Alphabet>;
	var alphabetModlist:Array<String> = [];

	var bg:FlxSprite;

	override function create()
	{
		super.create();

		// make sure there's nothing on the mod list
		alphabetModlist = [];

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		// reload locales
		ForeverLocales.getLocale(Init.trueSettings.get('Game Language'));

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set(0, 0.18);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xCE64DF;
		bg.antialiasing = !Init.getSetting('Disable Antialiasing');
		add(bg);

		for (mod in FileSystem.readDirectory('mods'))
		{
			if (!mod.contains('.'))
				alphabetModlist.push(mod);
		}

		alphaGroup = new FlxTypedGroup<Alphabet>();
		add(alphaGroup);

		for (i in 0...alphabetModlist.length)
		{
			var blah:Alphabet = new Alphabet(0, 0, alphabetModlist[i], true, false);
			blah.screenCenter();
			blah.y += (80 * (i - Math.floor(alphabetModlist[i].length / 2)));
			blah.y += 10;
			blah.targetY = i;
			blah.disableX = true;
			blah.isMenuItem = true;
			blah.alpha = 0.6;
			alphaGroup.add(blah);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			Main.switchState(this, new states.menus.MainMenuState());
	}
}
