package states.substates;

import base.ForeverAssets;
import base.MusicBeat.MusicBeatSubstate;
import dependency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.Alphabet;
import funkin.ui.menu.Checkmark;
import funkin.ui.menu.Selector;

typedef GameModifier =
{
	var name:String;
}

class FreeplaySubstate extends MusicBeatSubstate
{
	var gameplayMods:Array<GameModifier> = [
		{name: 'Enable Autoplay'},
		{name: 'Disable Deaths'}
	];

	var group:FlxTypedGroup<Alphabet>;
	var checkmarkGroup:FlxTypedGroup<Checkmark>;

	var curSelection:Int = 0;

	var lockedMovement = false;

	override function create()
	{
		super.create();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		group = new FlxTypedGroup<Alphabet>();
		add(group);

		checkmarkGroup = new FlxTypedGroup<Checkmark>();
		add(checkmarkGroup);

		for (i in 0...gameplayMods.length)
		{
			var modifiers:Alphabet = new Alphabet(0, (70 * i) + 30, gameplayMods[i].name, true, false);
			modifiers.isMenuItem = true;
			modifiers.disableX = true;
			modifiers.targetY = i;
			group.add(modifiers);

			var checkmark:Checkmark = ForeverAssets.generateCheckmark(10, modifiers.y, 'checkboxThingie', 'base', 'default', 'UI');
			checkmark.parent = modifiers;
			checkmark.playAnim(Std.string(/* Init.gameModifiers.get(group.members[curSelection].text) + */ 'false finished'));
			checkmarkGroup.add(checkmark);
		}

		updateSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			updateSelection(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (controls.UI_DOWN_P)
		{
			updateSelection(1);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		if (controls.ACCEPT)
		{
			lockedMovement = true;
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
			FlxFlicker.flicker(group.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				lockedMovement = false;
				updateOption();
			});
		}

		if (controls.BACK)
		{
			close();
		}
	}

	override public function close()
	{
		// Init.saveSettings();
		super.close();
	}

	function updateSelection(newSelection:Int = 0):Void
	{
		curSelection += newSelection;

		if (curSelection < 0)
			curSelection = gameplayMods.length - 1;
		if (curSelection >= gameplayMods.length)
			curSelection = 0;

		var bullShit:Int = 0;
		for (item in group.members)
		{
			item.targetY = bullShit - curSelection;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function updateOption()
	{
		Init.gameModifiers.set(group.members[curSelection].text, !Init.gameModifiers.get(group.members[curSelection].text));

		if (checkmarkGroup.members[curSelection] != null)
			checkmarkGroup.members[curSelection].playAnim(Std.string(Init.gameModifiers.get(group.members[curSelection].text)));
	}
}