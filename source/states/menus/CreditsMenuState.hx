package states.menus;

import base.MusicBeat.MusicBeatState;
import dependency.Discord;
import dependency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import funkin.Alphabet;
import funkin.ui.CreditsIcon;

using StringTools;

typedef CreditsPrefDef =
{
	var bgSprite:String;
	var bgAntialiasing:Bool;
	var users:Array<CreditsUserDef>;
}

typedef CreditsUserDef =
{
	var name:String;
	var icon:String;
	var textData:Array<String>;
	var colors:Array<Int>;
	var urlData:Array<Array<String>>;
	var sectionName:String;
}

/*
	New Credits Menu
	@author DiogoTVV and iamteles
	@origin VS Yung Lixo Rework
 */
class CreditsMenuState extends MusicBeatState
{
	var groupText:FlxText;

	static var curSelected:Int = -1;

	var curSocial:Int = -1;

	var userData:CreditsUserDef;
	var credData:CreditsPrefDef;

	var grpCharacters:FlxTypedGroup<Alphabet>;

	var iconArray:Array<CreditsIcon> = [];

	var mediaAnimsArray:Array<String> = ['NG', 'Twitter', 'Twitch', 'YT', 'GitHub'];

	var menuBack:FlxSprite;
	var backTween:FlxTween;
	var bDrop:FlxBackdrop;

	var socialIcon:FlxSprite;
	var leftArrow:FNFSprite;
	var rightArrow:FNFSprite;

	var grpCreditSocials:FlxGroup;

	var descBG:FlxSprite;
	var desc:FlxText;

	override function create()
	{
		super.create();

		credData = haxe.Json.parse(Paths.getTextFromFile('credits.json'));

		#if DISCORD_RPC
		Discord.changePresence('READING THE CREDITS', 'Credits Menu');
		#end

		generateBackground();

		grpCharacters = new FlxTypedGroup<Alphabet>();
		add(grpCharacters);

		grpCreditSocials = new FlxGroup();
		add(grpCreditSocials);

		for (i in 0...credData.users.length)
		{
			var personName:Alphabet = new Alphabet(0, (50 * i) + 30, credData.users[i].name, true, false, 0.85);
			personName.isMenuItem = true;
			personName.disableX = true;
			personName.targetY = i;
			personName.ID = i;
			grpCharacters.add(personName);

			var icon:CreditsIcon = new CreditsIcon(credData.users[i].icon);
			icon.sprTracker = personName;
			icon.scale.set(0.85, 0.85);
			icon.updateHitbox();

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			personName.x += 40;
		}

		descBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		descBG.alpha = 0.6;
		add(descBG);

		desc = new FlxText(40, 40, 1180, "Description.", 32);
		desc.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
		desc.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		desc.scrollFactor.set();
		desc.antialiasing = !Init.getSetting('Disable Antialiasing');
		add(desc);

		groupText = new FlxText(0, 40, 1180, "Group", 36);
		groupText.setFormat(Paths.font("vcr"), 36, FlxColor.WHITE, CENTER);
		groupText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		groupText.bold = true;
		groupText.scrollFactor.set();
		groupText.antialiasing = !Init.getSetting('Disable Antialiasing');
		add(groupText);

		socialIcon = new FlxSprite(0, 0);
		socialIcon.frames = Paths.getSparrowAtlas('credits/PlatformIcons');
		for (anim in mediaAnimsArray)
			socialIcon.animation.addByPrefix('$anim', '$anim', 24, false);
		socialIcon.scale.set(0.8, 0.8);
		socialIcon.updateHitbox();
		grpCreditSocials.add(socialIcon);

		leftArrow = generateUIArrows('left');
		grpCreditSocials.add(leftArrow);

		rightArrow = generateUIArrows('right');
		grpCreditSocials.add(rightArrow);

		curSelected = 0;
		curSocial = 0;
		changeSelection();
		updateSocial();
	}

	function generateBackground()
	{
		if (credData.bgSprite != null || credData.bgSprite.length > 0)
		{
			menuBack = new FlxSprite().loadGraphic(Paths.image(credData.bgSprite));
			menuBack.antialiasing = !credData.bgAntialiasing;
			menuBack.updateHitbox();
		}
		else
		{
			menuBack = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
			menuBack.antialiasing = !Init.getSetting('Disable Antialiasing');
		}
		add(menuBack);

		bDrop = new FlxBackdrop(Paths.image('menus/base/grid'), 8, 8, true, true, 1, 1);
		bDrop.velocity.x = 10;
		bDrop.screenCenter();
		bDrop.alpha = 0.5;
		add(bDrop);
	}

	function generateUIArrows(dir:String):FNFSprite
	{
		var selector = new FNFSprite();
		selector.frames = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');

		selector.animation.addByPrefix('idle', 'arrow $dir', 24, false);
		selector.animation.addByPrefix('press', 'arrow push $dir', 24, false);
		selector.addOffset('press', 0, -10);
		selector.playAnim('idle');

		return selector;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (backTween != null)
			backTween.cancel();
		backTween = FlxTween.color(menuBack, 0.35, menuBack.color, mainColor);

		// MESSY CONTROLS SECTION

		if (controls.UI_UP_P || (!FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel == 1))
			changeSelection(-1);
		else if (controls.UI_DOWN_P || (!FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel == -1))
			changeSelection(1);

		if (controls.UI_LEFT_P || (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel == 1))
			updateSocial(-1);
		else if (controls.UI_RIGHT_P || (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel == -1))
			updateSocial(1);

		if (controls.UI_LEFT || (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel == 1))
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');

		if (controls.UI_RIGHT || (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel == -1))
			rightArrow.animation.play('press')
		else
			rightArrow.animation.play('idle');

		if (controls.BACK || FlxG.mouse.justPressedRight)
			Main.switchState(this, new MainMenuState());

		if (controls.ACCEPT || FlxG.mouse.justPressed && credData.users[curSelected].urlData[curSocial][1] != null)
			CoolUtil.browserLoad(credData.users[curSelected].urlData[curSocial][1]);

		for (item in grpCharacters)
		{
			if (item.ID == curSelected)
				item.x = FlxMath.lerp(item.x, 100 + 20, 0.3);
			else if (item.ID == curSelected - 1 || item.ID == curSelected + 1)
				item.x = FlxMath.lerp(item.x, 50 + 20, 0.3);
			else
				item.x = FlxMath.lerp(item.x, 20, 0.3);
		}
	}

	var mainColor:FlxColor = FlxColor.WHITE;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = credData.users.length - 1;
		if (curSelected >= credData.users.length)
			curSelected = 0;

		mainColor = FlxColor.fromRGB(credData.users[curSelected].colors[0], credData.users[curSelected].colors[1], credData.users[curSelected].colors[2]);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpCharacters.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.color = FlxColor.fromRGB(155, 155, 155);

			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.color = FlxColor.WHITE;
			}
		}

		var quoteText:String;
		var validQuote = (credData.users[curSelected].textData[1] != null || credData.users[curSelected].textData[1].length >= 2);
		quoteText = (validQuote ? '\n' + '"' + credData.users[curSelected].textData[1] + '"' : '');

		desc.text = credData.users[curSelected].textData[0] + quoteText;
		desc.x = Math.floor((FlxG.width / 2) - (desc.width / 2));
		desc.y = FlxG.height - desc.height - 10;

		if (credData.users[curSelected].sectionName != null)
		{
			var textValue = credData.users[curSelected].sectionName;
			if (credData.users[curSelected].sectionName == null)
				textValue = "";
			groupText.text = textValue;
		}

		groupText.x = Math.floor((FlxG.width / 2) - (groupText.width / 2));
		groupText.y = desc.y - groupText.height - 10;
		descBG.y = groupText.y - 10;

		curSocial = 0;
		updateSocial(0, false);
	}

	public function updateSocial(huh:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSocial += huh;

		if (curSocial < 0)
			curSocial = credData.users[curSelected].urlData.length - 1;
		if (curSocial >= credData.users[curSelected].urlData.length)
			curSocial = 0;

		socialIcon.x = FlxG.width - socialIcon.width - 78;
		socialIcon.y = descBG.y - socialIcon.height - 8;

		leftArrow.x = FlxG.width - leftArrow.width - 238;
		leftArrow.y = descBG.y - socialIcon.height + 15;
		rightArrow.x = FlxG.width - rightArrow.width - 28;
		rightArrow.y = descBG.y - socialIcon.height + 15;

		socialIcon.animation.play(credData.users[curSelected].urlData[curSocial][0]);
	}
}
