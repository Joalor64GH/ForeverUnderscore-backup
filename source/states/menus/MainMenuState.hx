package states.menus;

import sys.FileSystem;
import base.MusicBeat.MusicBeatState;
import base.ScriptHandler;
import dependency.Discord;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import states.substates.PauseSubstate;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	public var menuItems:FlxTypedGroup<FlxSprite>;
	public static var curSelected:Float = 0;

	public var bg:FlxSprite;
	public var magenta:FlxSprite;
	public var camFollow:FlxObject;

	public var optionShit:Array<String> = ['story mode', 'freeplay', 'credits', 'options'];

	public var forceCenter:Bool = true;
	public var menuScript:ScriptHandler;

	public var menuItemScale:Int = 1;

	override function create()
	{
		super.create();

		var createOver:Dynamic = callFunc('overrideCreate', []);
		if (createOver != null) return;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		CreditsState.addSymbY = false;

		// uh
		persistentUpdate = persistentDraw = true;

		var paths:Array<String> = [
			Paths.getPreloadPath('classes/MenuState.hx'),
			Paths.getPreloadPath('classes/MenuState.hxs')
		];

		for (path in paths)
		{
			if (FileSystem.exists(path))
				menuScript = new ScriptHandler(path);
		}

		setVar('MainMenuState', this);
		setVar('add', this.add);
		setVar('remove', this.remove);
		setVar('destroy', this.destroy);

		callFunc('create', []);

		var vertScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menus/base/menuBG'));
		bg.scrollFactor.set(0, vertScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menus/base/menuDesat'));
		magenta.scrollFactor.set(0, vertScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			callFunc('optionSetup', []);
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.1);
			menuItem.frames = Paths.getSparrowAtlas('menus/base/menuItems/' + optionShit[i]);

			menuItem.scale.set(menuItemScale, menuItemScale);

			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;

			if (forceCenter)
				menuItem.screenCenter(X);
			if (menuItem.ID % 2 == 0)
				menuItem.x += 1000;
			else
				menuItem.x -= 1000;

			var newScroll:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6)
				newScroll = 0;

			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, newScroll);
			menuItem.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
			menuItem.updateHitbox();

			var vertLimit:Float = (Math.max(optionShit.length, 4) - 4) * 80;
			menuItem.y = 60 + (i * 160)  + vertLimit;
			setVar('menuItem', menuItem);
			callFunc('postOptionSetup', []);
		}

		var camLerp = Main.framerateAdjust(0.10);
		FlxG.camera.follow(camFollow, null, camLerp);

		updateSelection();

		var versionShit:FlxText = new FlxText(5, FlxG.height - 38, 0, "Friday Night Funkin v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var hash:String = '';
		if (Main.showCommitHash && Main.commitHash.length > 3)
			hash = Main.commitHash;

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Forever Engine v" + Main.foreverVersion + " • Underscore v" + Main.underscoreVersion + hash, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		if (optionShit.length < 2) // so you can't hardlock someone on the menu
			optionShit = ['story mode', 'freeplay', 'credits', 'options'];

		callFunc('postCreate', []);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		callFunc('update', [elapsed]);
		
		var setupOver:Dynamic = callFunc('overrideUpdate' [elapsed]);
		if (setupOver != null) return;

		if (!selectedSomethin)
		{
			if (controls.BACK || FlxG.mouse.justPressedRight)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
				Main.switchState(this, new TitleState());
			}

			var controlArray:Array<Bool> = [
				controls.UI_UP,
				controls.UI_DOWN,
				controls.UI_UP_P,
				controls.UI_DOWN_P,
				FlxG.mouse.wheel == 1,
				FlxG.mouse.wheel == -1
			];
			if ((controlArray.contains(true)))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i] == true)
					{
						if (i > 1)
						{
							if (i == 2 || i == 4)
								curSelected--;
							else if (i == 3 || i == 5)
								curSelected++;

							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						if (curSelected < 0)
							curSelected = optionShit.length - 1;
						else if (curSelected >= optionShit.length)
							curSelected = 0;
					}
				}
			}

		if ((controls.ACCEPT || FlxG.mouse.justPressed))
		{
			//
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			var flickerVal:Float = 0.06;

			if (Init.trueSettings.get('Disable Flashing Lights'))
				flickerVal = 1;
			if (!Init.trueSettings.get('Disable Flashing Lights'))
			FlxFlicker.flicker(magenta, 0.8, 0.1, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, flickerVal, false, false, function(flick:FlxFlicker)
						{
							switch (optionShit[Math.floor(curSelected)])
							{
								case 'story mode':
									Main.switchState(this, new StoryMenuState());
								case 'freeplay':
									Main.switchState(this, new FreeplayState());
								case 'credits':
									Main.switchState(this, new CreditsState());
								case 'options':
									PauseSubstate.toOptions = false;
									transIn = FlxTransitionableState.defaultTransIn;
									transOut = FlxTransitionableState.defaultTransOut;
									if (FlxG.keys.pressed.SHIFT)
										Main.switchState(this, new SettingsMenuState());
									else
										Main.switchState(this, new OptionsMenuState());
							}
						});
					}
				});
			}
		}

		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

		super.update(elapsed);

		menuItems.forEach(function(menuItem:FlxSprite)
		{
			if (forceCenter)
				menuItem.screenCenter(X);
		});
		callFunc('postUpdate', [elapsed]);
	}

	var lastCurSelected:Int = 0;

	function updateSelection()
	{
		callFunc('updateSelection', []);
		var selOver:Dynamic = callFunc('overrideUpdateSelection');
		if (selOver != null) return;
		// reset all selections
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			menuItems.members[Math.floor(curSelected)].scale.set(menuItemScale, menuItemScale);
		});

		var itemLength:Float = 0;
		if(menuItems.length > 4)
			itemLength = menuItems.length * 8;

		// set the sprites and all of the current selection
		camFollow.setPosition(menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().x,
			menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().y - itemLength);

		if (menuItems.members[Math.floor(curSelected)].animation.curAnim.name == 'idle')
			menuItems.members[Math.floor(curSelected)].animation.play('selected');

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
		callFunc('postUpdateSelection', []);
	}
	
	public function callFunc(key:String, args:Array<Dynamic>)
	{
		if (menuScript == null)
			return null;
		else
			return menuScript.call(key, args);
	}

	public function setVar(key:String, value:Dynamic)
	{
		if (menuScript == null)
			return null;
		else
			return menuScript.set(key, value);
	}
}
