package states.parents;

import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.menu.Checkmark;
import funkin.ui.menu.Selector;

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
 * a parent class for initializing categories and settings names for the settings menu
 */
class BaseSettingsMenu extends MusicBeatState
{
	public var categories:Array<Category> = [
		{name: 'GAMEPLAY', id: 1},
		{name: 'CONTROLS', id: 2},
		{name: 'VISUALS', id: 3},
		{name: 'ACCESSIBILITY', id: 4},
		{name: 'EXIT', id: -1}
	];

	public var options:Array<Option> = [

        // GAMEPLAY
		{name: 'Controller Mode', parentID: 1},
		{name: 'Downscroll', parentID: 1},
		{name: 'Centered Receptors', parentID: 1},
		{name: 'Ghost Tapping', parentID: 1},

        // VISUALS
		{name: 'Fixed Judgements', parentID: 3},
		{name: 'Colored Health Bar', parentID: 3},
		{name: 'Animated Score Color', parentID: 3},
		{name: 'GPU Rendering', parentID: 1},
		{name: 'Counter', parentID: 3},
		{name: 'Note Skin', parentID: 3},
		{name: 'Arrow Opacity', parentID: 3},
		{name: 'UI Skin', parentID: 3},

		// ACCESSIBILITY
		{name: 'Disable Antialiasing', parentID: 4},
		{name: 'Disable Flashing Lights', parentID: 4},
		{name: 'Disable Shaders', parentID: 4},
		{name: 'Reduced Movements', parentID: 4},
		{name: 'Stage Opacity', parentID: 4},
		{name: 'Filter', parentID: 4}
	];

	public var curCategory = 0;
	public var curSelected = 0;

	public var checkmarkGroup:FlxTypedGroup<Checkmark>;
    public var selectorGroup:FlxTypedGroup<Selector>;

    var bg:FlxSprite;
	var coolGrid:FlxBackdrop;

	function generateBackground()
	{
		bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xCE64DF;
		bg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		add(bg);
        
		coolGrid = new FlxBackdrop(null, 1, 1, true, true, 1, 1);
		coolGrid.loadGraphic(Paths.image('menus/chart editor/grid'));
		coolGrid.alpha = (32 / 255);
		add(coolGrid);
	}

	public function generateCheckmarks()
    {
		if (checkmarkGroup != null)
			remove(checkmarkGroup);

		checkmarkGroup = new FlxTypedGroup<Checkmark>();
		add(checkmarkGroup);
    }

	public function generateSelectors()
	{
		if (selectorGroup != null)
			remove(selectorGroup);

		selectorGroup = new FlxTypedGroup<Selector>();
		add(selectorGroup);
	}

	public function updateSelector(selector:Selector, updateBy:Int)
	{
		var fps = selector.optionBooleans[0];
		var bgdark = selector.optionBooleans[1];
		var hitVol = selector.optionBooleans[2];
		var scrollspeed = selector.optionBooleans[3];
		var strumlineOp = selector.optionBooleans[4];
		var notesplashOp = selector.optionBooleans[5];

		/**
		 * left to right, minimum value, maximum value, change value
		 * rest is default stuff that I needed to keep
		**/
		if (fps)
			generateSelector(30, 360, 15, updateBy, selector);
		else if (bgdark || hitVol)
			generateSelector(0, 100, 5, updateBy, selector);
		else if (scrollspeed)
			generateSelector(1, 6, 0.1, updateBy, selector);
		else if (strumlineOp || notesplashOp)
			generateSelector(0, 100, 10, updateBy, selector);
		if (!fps && !bgdark && !hitVol && !scrollspeed && !strumlineOp && !notesplashOp)
		{
			// get the current option as a number
			var storedNumber:Int = 0;
			var newSelection:Int = storedNumber;
			if (selector.options != null)
			{
				for (curOption in 0...selector.options.length)
				{
					if (selector.options[curOption] == selector.optionChosen.text)
						storedNumber = curOption;
				}

				newSelection = storedNumber + updateBy;
				if (newSelection < 0)
					newSelection = selector.options.length - 1;
				else if (newSelection >= selector.options.length)
					newSelection = 0;
			}

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			selector.chosenOptionString = selector.options[newSelection];
			selector.optionChosen.text = selector.chosenOptionString;

			Init.trueSettings.set(options[curSelected].name, selector.chosenOptionString);
			Init.saveSettings();
		}
	}

	public function generateSelector(min:Float = 0, max:Float = 100, inc:Float = 5, updateBy:Int, selector:Selector)
	{
		// lazily hardcoded??
		var originalValue = Init.trueSettings.get(options[curSelected].name);
		var increase = inc * updateBy;
		// min
		if (originalValue + increase < min)
			increase = 0;
		// max
		if (originalValue + increase > max)
			increase = 0;

		if (updateBy == -1)
			selector.selectorPlay('left', 'press');
		else
			selector.selectorPlay('right', 'press');

		FlxG.sound.play(Paths.sound('scrollMenu'));

		originalValue += increase;
		selector.chosenOptionString = Std.string(originalValue);
		selector.optionChosen.text = Std.string(originalValue);
		Init.trueSettings.set(options[curSelected].name, originalValue);
		Init.saveSettings();
	}
}