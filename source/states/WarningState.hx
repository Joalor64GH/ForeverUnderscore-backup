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
	a state for general warnings
	this is just code from the base game that i've made some slight improvements to
**/
class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warningText:FlxText;
	var warningType:String = 'flashing';

	var textField:String = 'beep bop bo skdkdkdbebedeoop brrapadop';
	var fieldOffset:Float = 0;

	public function new(warningType:String = 'flashing')
	{
		super();
		this.warningType = warningType;
	}

	override function create()
	{
		super.create();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// uh
		persistentUpdate = persistentDraw = true;

		switch (warningType)
		{
			case 'update':
				textField = "Hey, You're running an outdated version of"
					+ "\nForever Engine Underscore"
					+ "\n\nPress ENTER to Update from "
					+ Main.underscoreVersion
					+ ' to '
					+ ForeverTools.updateVersion
					+ '\nPress ESCAPE to ignore this message.'
					+ "\n\nif you wish to disable this\nUncheck \"Check for Updates\" on the Options Menu";
			case 'flashing':
				textField = "Hey, quick notice that this mod contains Flashing Lights"
					+ "\nYou can Press ENTER to disable them now or ESCAPE to ignore"
					+ "\nyou can later manage flashing lights and other\naccessibility settings by going to the Options Menu"
					+ "\n\nYou've been warned\n";
				fieldOffset = 50;
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warningText = new FlxText(0, 0, FlxG.width - fieldOffset, textField, 32);
		warningText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warningText.screenCenter();
		warningText.alpha = 0;
		warningText.antialiasing = !Init.getSetting('Disable Antialiasing');
		add(warningText);

		FlxTween.tween(warningText, {alpha: 1}, 0.4);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT || controls.BACK)
		{
			FlxTransitionableState.skipNextTransIn = true;
			textFinishCallback(warningType);
		}
	}

	function textFinishCallback(type:String = 'flashing')
	{
		switch (type)
		{
			case 'update':
				leftState = true;

				if (!controls.BACK)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warningText, 1, 0.06 * 2, true, false, function(flick:FlxFlicker)
					{
						warningText.alpha = 0;
						CoolUtil.browserLoad('https://github.com/BeastlyGhost/Forever-Engine-Underscore');
						Main.switchState(this, new MainMenuState());
					});
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warningText, {alpha: 0}, 0.6, {
						onComplete: function(twn:FlxTween)
						{
							Main.switchState(this, new MainMenuState());
						}
					});
				}
			case 'flashing':
				Init.trueSettings.set('Left Flashing State', true);

				if (!controls.BACK)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					Init.trueSettings.set('Disable Flashing Lights', true);
					FlxFlicker.flicker(warningText, 1, 0.06 * 2, true, false, function(flick:FlxFlicker)
					{
						warningText.alpha = 0;
						Main.switchState(this, new TitleState());
					});
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warningText, {alpha: 0}, 0.6, {
						onComplete: function(twn:FlxTween)
						{
							Main.switchState(this, new TitleState());
						}
					});
				}
		}
	}
}
