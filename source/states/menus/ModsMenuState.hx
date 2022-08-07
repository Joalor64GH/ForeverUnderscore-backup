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
    hasLoadingScreen:Bool,
    loadingImage:String,
    loadingBarColor:Array<FlxColor>,
}

/**
* people have been asking and stuff so here it is
* this is gonna be slooow to finish though, as I already need to finish the offset and chart editors
* but here it is, I will need a lot of help, but here it is!

* quick reminder, i'm not a very good programmer, but I will try my very best -gabi
**/

class ModsMenuState extends MusicBeatState
{
    var bg:FlxSprite;
    var fg:FlxSprite;

    var modList:Array<String> = [];

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

        var text:FlxText = new FlxText(0, 0, 0, '- MODS MENU -\nWIP\n');
		text.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE);
		text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		text.antialiasing = true;
		add(text);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.BACK)
        {
            Main.switchState(this, new MainMenuState());
        }
    }
}