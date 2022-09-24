package states;

import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import states.menus.MainMenuState;

/**
	a state for warning about new engine updates and such
	this is just code from the base game that i've made some slight improvements to
**/

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false; // so you won't get to this substate again until you restart the game;
	var updateText:FlxText;

    override function create()
    {
        super.create();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// uh
		persistentUpdate = persistentDraw = true;
		
		#if GAME_UPDATER
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		updateText = new FlxText(0, 0, FlxG.width,
			"Hey, You're running an outdated version of Forever Engine Underscore
			\nPress ENTER to Update\nfrom "
			+ Main.underscoreVersion
			+ ' to '
			+ ForeverTools.updateVersion
			+ '\nPress ESCAPE to ignore this message.
			\nif you wish to disable this, Uncheck "Check for Updates" on the Options Menu',
			32);
		updateText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		updateText.screenCenter();
		updateText.alpha = 0;
		updateText.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		add(updateText);

		FlxTween.tween(updateText, {alpha: 1}, 0.4);
		#else
		Main.switchState(this, new MainMenuState());
		#end
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var accept:Bool = controls.ACCEPT;
		var back:Bool = controls.BACK;

		if (accept || back)
		{
			leftState = true;
			if (!back)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxFlicker.flicker(updateText, 1, 0.06 * 2, true, false, function(flick:FlxFlicker)
				{
					CoolUtil.browserLoad('https://github.com/BeastlyGhost/Forever-Engine-Underscore');
					Main.switchState(this, new MainMenuState());
				});
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(updateText, {alpha: 0}, 0.6, {
					onComplete: function(twn:FlxTween)
					{
						Main.switchState(this, new MainMenuState());
					}
				});
			}
		}
	}
}
