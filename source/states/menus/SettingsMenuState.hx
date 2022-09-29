package states.menus;

import dependency.Discord;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.Alphabet;
import funkin.ui.menu.Checkmark;
import funkin.ui.menu.Selector;
import states.parents.BaseSettingsMenu;
import states.substates.ControlsSubstate;
import states.substates.PauseSubstate;

/**
 * options menu rewrite, heavily based on Forever 1.0's Options Menu
 * because the old one felt too overcomplicated
 * no offense yoshubs.
 */
class SettingsMenuState extends BaseSettingsMenu
{
	var topBar:FlxSprite;
	var bottomBar:FlxSprite;
	var topMarker:FlxText;
	var rightMarker:FlxText;
	var bottomMarker:FlxText;

	var currentGroup:FlxTypedGroup<Alphabet>;

	var lockedMovement:Bool = false;

	override public function create()
	{
		super.create();

		#if DISCORD_RPC
		Discord.changePresence('ADJUSTING PREFERENCES', 'Options Menu');
		#end

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		generateBackground();
		reloadObjects();

		topBar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		topBar.setGraphicSize(FlxG.width, 48);
		topBar.updateHitbox();
		topBar.screenCenter(X);

		bottomBar = new FlxSprite().loadGraphic(topBar.graphic);
		bottomBar.setGraphicSize(FlxG.width, 48);
		bottomBar.updateHitbox();
		bottomBar.screenCenter(X);

		add(topBar);
		topBar.y -= topBar.height;
		add(bottomBar);
		bottomBar.y += FlxG.height;

		topMarker = new FlxText(8, 8, 0, "SETTINGS").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		topMarker.alpha = 0;
		add(topMarker);

		rightMarker = new FlxText(8, 8, 0, "FOREVER ENGINE: UNDERSCORE").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		rightMarker.x += FlxG.width - (rightMarker.width + 16);
		rightMarker.alpha = 0;
		add(rightMarker);

		bottomMarker = new FlxText(8, 8, 0, "").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		bottomMarker.alpha = 0;
		add(bottomMarker);

		FlxTween.tween(topMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(rightMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(bottomMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		topBar.y = FlxMath.lerp(topBar.y, 0, elapsed * 6);
		bottomBar.y = FlxMath.lerp(bottomBar.y, FlxG.height - bottomBar.height, elapsed * 6);
		topMarker.y = topBar.y + 5;
		rightMarker.y = topBar.y + 5;
		bottomMarker.y = bottomBar.y + 5;

		if (bottomMarker.text.length > 61)
		{
			bottomMarker.size = 28;
			bottomMarker.y = bottomBar.y;
		}
		else
		{
			bottomMarker.scale.set(1, 1);
		}

		if (Init.gameSettings.get(currentGroup.members[curSelected].text) != null)
		{
			var currentSetting = Init.gameSettings.get(currentGroup.members[curSelected].text);
			var textValue = currentSetting[2];
			if (textValue == null)
				textValue = "";
			bottomMarker.text = textValue;
		}

		if (!lockedMovement)
		{
			if (controls.UI_UP_P)
				updateSelection(-1);
			if (controls.UI_DOWN_P)
				updateSelection(1);

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));

				if (curCategory == 0)
				{
					if (!PauseSubstate.toOptions)
						Main.switchState(this, new MainMenuState());
					else
						Main.switchState(this, new PlayState());
				}
				else
				{
					curCategory = 0;
					topMarker.text = 'SETTINGS';
					bottomMarker.text = '';
					reloadObjects();
				}
			}

			if (controls.ACCEPT)
			{
				lockedMovement = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (curCategory == 0)
				{
					switch (currentGroup.members[curSelected].text.toLowerCase())
					{
						case 'controls':
							FlxFlicker.flicker(currentGroup.members[curSelected], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
							{
								openSubState(new ControlsSubstate());
								lockedMovement = false;
							});
						case 'exit':
							FlxFlicker.flicker(currentGroup.members[curSelected], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
							{
								if (!PauseSubstate.toOptions)
									Main.switchState(this, new MainMenuState());
								else
									Main.switchState(this, new PlayState());
								lockedMovement = false;
							});
						default: // anything else;
							FlxFlicker.flicker(currentGroup.members[curSelected], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
							{
								goToCategory(curSelected);
								lockedMovement = false;
							});
					}
				}
				else
				{
					FlxFlicker.flicker(currentGroup.members[curSelected], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
					{
						selectOption('checkmark');
						lockedMovement = false;
					});
				}
			}
		}
	}

	public function updateSelection(newSelec:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += newSelec;

		if (curSelected < 0)
			curSelected = currentGroup.length - 1;
		else if (curSelected >= currentGroup.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in currentGroup.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function reloadObjects()
	{
		// kill previous instances of used groups;

		if (currentGroup != null)
			remove(currentGroup);

		// generate new instances for those groups;
		currentGroup = new FlxTypedGroup<Alphabet>();
		add(currentGroup);

		generateCheckmarks();
		generateSelectors();

		if (curCategory != 0)
		{
			reloadOptions();
		}
		else
		{
			// create categories
			for (i in 0...categories.length)
			{
				var baseAlphabet:Alphabet = new Alphabet(0, 0, categories[i].name, true, false);
				baseAlphabet.screenCenter();
				baseAlphabet.y += (80 * (i - Math.floor(categories.length / 2)));
				baseAlphabet.y += 50;
				baseAlphabet.targetY = i;
				baseAlphabet.disableX = true;
				if (curCategory > 0)
					baseAlphabet.isMenuItem = true;
				baseAlphabet.alpha = 0.6;
				currentGroup.add(baseAlphabet);
			}
		}

		// reset selection
		curSelected = 0;
		updateSelection(0, false);
	}

	function goToCategory(nextCategory:Int)
	{
		topMarker.text = categories[nextCategory].name;
		curCategory = categories[nextCategory].id;
		reloadObjects();
	}

	function reloadOptions()
	{
		for (i in 0...options.length)
		{
			if (curCategory == options[i].parentID)
			{
				if (Init.gameSettings.get(options[i].name)[0] == null || Init.gameSettings.get(options[i].name)[3] != Init.FORCED)
				{
					var baseAlphabet:Alphabet = new Alphabet(0, 0, options[i].name, true, false);
					baseAlphabet.screenCenter();
					baseAlphabet.y += (90 * (i - Math.floor(options.length / 2)));
					baseAlphabet.targetY = i;
					baseAlphabet.disableX = true;
					baseAlphabet.isMenuItem = true;
					baseAlphabet.alpha = 0.6;
					currentGroup.add(baseAlphabet);

					// generates an attached texture depending on the setting type
					switch (Init.gameSettings.get(options[i].name)[1])
					{
						case Init.SettingTypes.Checkmark:
							var checkmark:Checkmark = ForeverAssets.generateCheckmark(10, baseAlphabet.y - 40, 'checkboxThingie', 'base', 'default', 'UI');
							checkmark.parent = baseAlphabet;
							checkmark.playAnim(Std.string(Init.getSetting(options[i].name)) + ' finished');
							checkmarkGroup.add(checkmark);
						case Init.SettingTypes.Selector:
							var selector:Selector = new Selector(10, currentGroup.members[curSelected].y, options[curSelected].name,
								Init.gameSettings.get(options[curSelected].name)[4], [
									(options[curSelected].name == 'Framerate Cap')
									? true : false,
									(options[curSelected].name == 'Darkness Opacity')
									? true : false,
									(options[curSelected].name == 'Hitsound Volume')
									? true : false,
									(options[curSelected].name == 'Scroll Speed')
									? true : false,
									(options[curSelected].name == 'Arrow Opacity')
									? true : false,
									(options[curSelected].name == 'Splash Opacity' ? true : false)
								]);
							selectorGroup.add(selector);
						default:
							// do nothing;
					}
				}
			}
		}
	}

	function selectOption(type:String = 'bool')
	{
		var settingType = Init.gameSettings.get(options[curSelected].name)[1];

		switch (settingType)
		{
			case Init.SettingTypes.Checkmark:
				if (type == 'checkmark')
				{
					Init.setSetting(options[curSelected].name, !Init.getSetting(options[curSelected].name));
					if (checkmarkGroup.members[curSelected] != null)
						checkmarkGroup.members[curSelected].playAnim(Std.string(Init.getSetting(options[curSelected].name)));
					Init.saveSettings();
				}
			case Init.SettingTypes.Selector:
				var selector:Selector = selectorGroup.members[curSelected];

				if (!controls.UI_LEFT)
					selector.selectorPlay('left');
				if (!controls.UI_RIGHT)
					selector.selectorPlay('right');

				if (controls.UI_RIGHT_P)
					updateSelector(selector, 1);
				else if (controls.UI_LEFT_P)
					updateSelector(selector, -1);
			default:
				// do nothing;
		}
		// trace(Init.getSetting(options[curSelected].name));
	}
}
