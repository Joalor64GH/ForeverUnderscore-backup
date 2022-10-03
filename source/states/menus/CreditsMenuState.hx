package states.menus;

import base.MusicBeat.MusicBeatState;
import dependency.Discord;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.Alphabet;
import funkin.ui.CreditsIcon;

using StringTools;
typedef CreditsUserDef =
{
	var name:String;
	var icon:String;
	var textData:Array<String>;
	var colors:Array<Int>;
	var urlData:Array<Array<String>>;
	var ?sectionName:String;
}

typedef CreditsPrefDef =
{
	var ?menuBG:Null<String>;
	var ?menuBGColor:Null<Array<Int>>;
	var ?tweenColor:Null<Bool>;
	var users:Array<CreditsUserDef>;
}

/*
	New Credits Menu
	Written by: @DiogoTVV and @iamteles
*/
class CreditsMenuState extends MusicBeatState
{
	var groupText:FlxText;
	static var curSelected:Int = -1;
	var curSocial:Int = -1;

	var userData:CreditsUserDef;
	var credData:CreditsPrefDef;

	private var grpCharacters:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<CreditsIcon> = [];

	private var bgTween:FlxTween;
	private var bg:FlxSprite;
	private var bDrop:FlxBackdrop;

	private var socialIcon:FlxSprite;

	private var descBG:FlxSprite;
	private var desc:FlxText;

	override function create()
	{
		super.create();

		credData = haxe.Json.parse(Paths.getTextFromFile('credits.json'));

		#if DISCORD_RPC
		Discord.changePresence('READING THE CREDITS', 'Credits Menu');
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		add(bg);

		bDrop = new FlxBackdrop(Paths.image('menus/base/grid'), 8, 8, true, true, 1, 1);
		bDrop.velocity.x = 10;
		bDrop.screenCenter();
		bDrop.alpha = 0.8;
		add(bDrop);
		
		var white:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		white.scrollFactor.set();
		white.screenCenter();
		white.antialiasing = true;
		white.alpha = 0.25;
		add(white);

		grpCharacters = new FlxTypedGroup<Alphabet>();
		add(grpCharacters);

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
		desc.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		desc.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		desc.scrollFactor.set();
		desc.antialiasing = true;
		add(desc);

		groupText = new FlxText(0, 40, 1180, "Group", 36);
		groupText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER);
		groupText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		groupText.bold = true;
		groupText.scrollFactor.set();
		groupText.antialiasing = true;
		add(groupText);

		socialIcon = new FlxSprite(0,0);
		socialIcon.frames = Paths.getSparrowAtlas('credits/PlatformIcons');
		socialIcon.animation.addByPrefix('NG', 'NG', 24, false);
		socialIcon.animation.addByPrefix('Twitter', 'Twitter', 24, false);
		socialIcon.animation.addByPrefix('Twitch', 'Twitch', 24, false);
		socialIcon.animation.addByPrefix('YouTube', 'YT', 24, false);
		socialIcon.animation.play('base');
		socialIcon.scale.set(0.8,0.8);
		socialIcon.updateHitbox();
		add(socialIcon);

		curSelected = 0;
		curSocial = 0;
		changeSelection();
		updateSocial();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		else if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			updateSocial(-1);
		else if (controls.UI_RIGHT_P)
			updateSocial(1);

		if (controls.BACK)
			Main.switchState(this, new MainMenuState());

		if (controls.ACCEPT && credData.users[curSelected].urlData[curSocial][1] != null)
			CoolUtil.browserLoad(credData.users[curSelected].urlData[curSocial][1]);
		
		for (item in grpCharacters)
		{
			if(item.ID == curSelected)
				item.x = FlxMath.lerp(item.x, 100 + 20, 0.3);
			else if(item.ID == curSelected - 1 || item.ID == curSelected + 1)
				item.x = FlxMath.lerp(item.x, 50 + 20, 0.3);
			else
				item.x = FlxMath.lerp(item.x, 20, 0.3);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = credData.users.length - 1;
		if (curSelected >= credData.users.length)
			curSelected = 0;

		var newColor:FlxColor = FlxColor.fromRGB(credData.users[curSelected].colors[0], credData.users[curSelected].colors[1],
			credData.users[curSelected].colors[2]);

		if(bgTween != null)
			bgTween.cancel();
		bgTween = FlxTween.color(bg, 0.35, bg.color, newColor);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpCharacters.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.color = FlxColor.fromRGB(155,155,155);

			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.color = FlxColor.WHITE;
			}
		}

		var quoteText:String;
		var validQuote = (credData.users[curSelected].textData[1] != null || credData.users[curSelected].textData[1].length >= 2);
		quoteText = (validQuote ? '\n' + credData.users[curSelected].textData[1] : '');

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
		updateSocial();
	}

	public function updateSocial(huh:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSocial += huh;

		if (curSocial < 0)
			curSocial = credData.users[curSelected].urlData[0].length - 1;
		if (curSocial >= credData.users[curSelected].urlData.length)
			curSocial = 0;

		socialIcon.x = FlxG.width - socialIcon.width - 8;
		socialIcon.y = descBG.y - socialIcon.height - 8;
		socialIcon.animation.play(credData.users[curSelected].urlData[curSocial][0]);
	}
}
