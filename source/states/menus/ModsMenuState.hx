package states.menus;

import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.Alphabet;
import haxe.Json;

typedef ModData =
{
	name:String,
	icon:String,
	description:String,
	tags:Array<String>,
	authors:Array<String>,
	loadingImage:String,
	loadingBarColor:Array<FlxColor>,
}

/**
	* people have been asking and stuff so here it is
	* this is gonna be slooow to finish though, as I already need to finish the offset and chart editors
	* but here it is, I will need a lot of help, but here it is!

	* quick reminder, i'm not a very good programmer, but I will try my very best -gabi
	* no, I have NO ideas for this.
**/
class ModsMenuState extends MusicBeatState
{
	// look I don't feel like commenting specific lines on a MODS menu.
	#if MODS_ALLOWED
	var bg:FlxSprite;
	var fg:FlxSprite;
	var infoText:FlxText;

	var curMod:Int = -1;
	var curSelection:Int = -1;

	var modList:Array<String> = [null];

	override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xCE64DF;
		add(bg);

		fg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		fg.alpha = 0;
		fg.scrollFactor.set();
		add(fg);

		FlxTween.tween(fg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		var text:FlxText = new FlxText(0, 0, 0, '- MODS MENU -');
		text.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE);
		text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		text.antialiasing = true;
		text.screenCenter(X);
		add(text);

		infoText = new FlxText(5, FlxG.height - 24, 0, "", 32);
		infoText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = FlxColor.BLACK;
		add(infoText);

		for (modFolders in Paths.getModDirs())
		{
			modList.push(modFolders);
		}

		var mod:Int = modList.indexOf(Paths.currentPack);
		if (mod > -1)
			curMod = mod;

		changeMod();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			Main.switchState(this, new MainMenuState());
		}
		if (controls.UI_LEFT_P)
			changeMod(-1);
		if (controls.UI_RIGHT_P)
			changeMod(1);
	}

	function changeMod(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curMod += change;

		if (curMod < 0)
			curMod = modList.length - 1;
		if (curMod >= modList.length)
			curMod = 0;

		if (modList[curMod] == null || modList[curMod].length < 1)
		{
			infoText.text = '[NO MODS LOADED]';
			Paths.currentPack = Paths.defaultPack;
		}
		else
		{
			Paths.currentPack = modList[curMod];
			infoText.text = '[LOADED MOD: ' + Paths.currentPack + ']';
		}
		infoText.text = infoText.text.toUpperCase();
	}
	#end
}