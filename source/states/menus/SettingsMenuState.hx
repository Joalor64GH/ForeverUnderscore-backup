package states.menus;

import Init.SettingTypes;
import base.ForeverAssets;
import base.ForeverTools;
import base.MusicBeat.MusicBeatState;
import dependency.FNFSprite;
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
import states.substates.ControlsSubstate;
import states.substates.PauseSubstate;

typedef Category =
{
	var name:String; // the category name
	var id:Int; // the category ID (used for selections)
}

typedef Option =
{
	var name:String; // the option name on Init
	var parentID:Int; // the category ID associated with the option
}

/**
 * options menu rewrite, heavily based on Forever 1.0's Options Menu
 * because the old one felt too overcomplicated
 * no offense yoshubs.
 */
class SettingsMenuState extends MusicBeatState
{
	var topBar:FlxSprite;
	var bottomBar:FlxSprite;
	var topMarker:FlxText;
	var rightMarker:FlxText;
	var bottomMarker:FlxText;

	var currentGroup:FlxTypedGroup<Alphabet>;
	var checkmarkGroup:FlxTypedGroup<Checkmark>;

	var lockedMovement:Bool = false;

	public var categories:Array<Category> = [
		{name: 'GAMEPLAY', id: 1},
		{name: 'CONTROLS', id: 2},
		{name: 'VISUALS', id: 3},
		{name: 'ACCESSIBILITY', id: 4},
		{name: 'EXIT', id: -1}
	];

	public var options:Array<Option> = [
		{name: 'Controller Mode', parentID: 1},
		{name: 'Downscroll', parentID: 1},
		{name: 'Centered Receptors', parentID: 1},
		{name: 'Ghost Tapping', parentID: 1},
		{name: 'UI Skin', parentID: 3},
		{name: 'Disable Antialiasing', parentID: 4},
		{name: 'Disable Flashing Lights', parentID: 4},
		{name: 'Disable Shaders', parentID: 4},
		{name: 'Reduced Movements', parentID: 4},
		{name: 'Stage Opacity', parentID: 4},
		{name: 'Filter', parentID: 4}
	];

	public var curCategory = 0;
	public var curSelected = 0;

	override public function create()
	{
		super.create();

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

	function generateBackground()
	{
		var bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xCE64DF;
		bg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		add(bg);
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
			bottomMarker.size = 26;
			bottomMarker.y = bottomBar.y;
		}
		else
		{
			bottomMarker.size = 32;
			bottomMarker.y = bottomBar.y + 5;
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
						selectOption();
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

		if (checkmarkGroup != null)
			remove(checkmarkGroup);

		// generate new instances for those groups;
		currentGroup = new FlxTypedGroup<Alphabet>();
		add(currentGroup);

		checkmarkGroup = new FlxTypedGroup<Checkmark>();
		add(checkmarkGroup);

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
				baseAlphabet.y += (90 * (i - Math.floor(categories.length / 2)));
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
							checkmark.playAnim(Std.string(Init.trueSettings.get(options[i].name)) + ' finished');
							checkmarkGroup.add(checkmark);
						default:
							// do nothing;
					}
				}
			}
		}
	}

	function selectOption()
	{
		var settingType = Init.gameSettings.get(options[curSelected].name)[1];

		switch (settingType)
		{
			case Init.SettingTypes.Checkmark:
				Init.trueSettings.set(options[curSelected].name, !Init.trueSettings.get(options[curSelected].name));
				if (checkmarkGroup.members[curSelected] != null)
					checkmarkGroup.members[curSelected].playAnim(Std.string(Init.trueSettings.get(options[curSelected].name)));
				Init.saveSettings();
			default:
				// do nothing;
		}
		//trace(Init.trueSettings.get(options[curSelected].name));
	}
}