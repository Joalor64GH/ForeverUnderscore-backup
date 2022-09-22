package states.menus;

import haxe.Json;
import base.MusicBeat.MusicBeatState;
import dependency.AbsoluteSprite;
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

typedef CreditsUserDef =
{
	var name:String;
	var iconData:Array<Dynamic>;
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

class CreditsState extends MusicBeatState
{
	static var curSelection = -1;
	var curSocial = -1;

	var alphabetGroup:FlxTypedGroup<Alphabet>;

	var menuBG:FlxSprite = new FlxSprite();
	var menuColorTween:FlxTween;

	var userData:CreditsUserDef;
	var credData:CreditsPrefDef;

	var iconArray:Array<AbsoluteSprite> = [];

	public static var addSymbY:Bool = false;

	override function create()
	{
		super.create();

		addSymbY = true;

		credData = Json.parse(Paths.getTextFromFile('credits.json'));

		#if DISCORD_RPC
		Discord.changePresence('READING THE CREDITS', 'Credits Menu');
		#end

		if (credData.menuBG != null && credData.menuBG.length > 0)
			menuBG.loadGraphic(Paths.image(credData.menuBG));
		else
			menuBG.loadGraphic(Paths.image('menus/base/menuDesat'));

		menuBG.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		menuBG.screenCenter();
		add(menuBG);

		var finalColor:FlxColor = FlxColor.fromRGB(credData.menuBGColor[0], credData.menuBGColor[1], credData.menuBGColor[2]);
		if (!credData.tweenColor)
			menuBG.color = finalColor;

		alphabetGroup = new FlxTypedGroup<Alphabet>();
		add(alphabetGroup);

		for (i in 0...credData.users.length)
		{
			var personName:Alphabet = new Alphabet(0, (70 * i) + 30, credData.users[i].name, false, false);
			personName.isMenuItem = true;
			personName.disableX = true;
			personName.targetY = i;
			alphabetGroup.add(personName);

			var iconGraphic = 'credits/' + credData.users[i].iconData[0];
			var icon:AbsoluteSprite = new AbsoluteSprite(iconGraphic, personName, credData.users[i].iconData[1], credData.users[i].iconData[2]);

			if (credData.users[i].iconData[3] != null)
				icon.setGraphicSize(Std.int(icon.width * credData.users[i].iconData[3]));

			if (credData.users[i].iconData.length <= 1 || credData.users[i].iconData == null)
				icon.visible = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			if (curSelection == -1)
				curSelection = i;
		}

		if (curSocial == -1)
			curSocial = 0;

		generateMarkers();
		updateSelection();
	}

	var topBar:FlxSprite;
	var topMarker:FlxText;
	var rightMarker:FlxText;
	var bottomMarker:FlxText;
	var centerMarker:FlxText;

	function generateMarkers()
	{
		topBar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		topBar.setGraphicSize(FlxG.width, 48);
		topBar.updateHitbox();
		topBar.screenCenter(X);

		add(topBar);
		topBar.y -= topBar.height;

		topMarker = new FlxText(8, 8, 0, "CREDITS").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		topMarker.alpha = 0;
		add(topMarker);

		centerMarker = new FlxText(8, 8, 0, "<NEWGROUNDS>").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		centerMarker.screenCenter(X);
		centerMarker.alpha = 0;
		add(centerMarker);

		rightMarker = new FlxText(8, 8, 0, "FOREVER ENGINE: UNDERSCORE").setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE);
		rightMarker.x = FlxG.width - (rightMarker.width + 16);
		rightMarker.alpha = 0;
		add(rightMarker);

		bottomMarker = new FlxText(5, FlxG.height - 24, 0, "", 32);
		bottomMarker.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		bottomMarker.textField.background = true;
		bottomMarker.textField.backgroundColor = FlxColor.BLACK;
		add(bottomMarker);

		FlxTween.tween(topMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(centerMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(rightMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		topBar.y = FlxMath.lerp(topBar.y, 0, elapsed * 6);
		topMarker.y = topBar.y + 5;
		centerMarker.y = topBar.y + 5;

		rightMarker.y = topBar.y + 5;

		rightMarker.x = FlxG.width - (rightMarker.width + 16);

		bottomMarker.screenCenter(X);

		// CONTROLS //

		var controlArray:Array<Bool> = [controls.UI_UP, controls.UI_DOWN, controls.UI_UP_P, controls.UI_DOWN_P, FlxG.mouse.wheel == 1, FlxG.mouse.wheel == -1];
		if ((controlArray.contains(true)))
		{
			for (i in 0...controlArray.length)
			{
				if (controlArray[i] == true)
				{
					if (i > 1)
					{
						if (i == 2 || i == 4)
							curSelection--;
						else if (i == 3 || i == 5)
							curSelection++;

						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					if (curSelection < 0)
						curSelection = credData.users.length - 1;
					else if (curSelection >= credData.users.length)
						curSelection = 0;
					updateSelection();
				}
			}
		}

		if (controls.UI_LEFT_P)
			updateSocial(-1);

		if (controls.UI_RIGHT_P)
			updateSocial(1);

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxFlicker.flicker(alphabetGroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				if (credData.users[curSelection].urlData[curSocial][1] != null)
					CoolUtil.browserLoad(credData.users[curSelection].urlData[curSocial][1]);
			});
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Main.switchState(this, new MainMenuState());
			Paths.clearUnusedMemory();
		}

		updateBottomMarker();
	}

	function updateSelection()
	{
		var bullShit:Int = 0;
		for (item in alphabetGroup.members)
		{
			item.targetY = bullShit - curSelection;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

		if (credData.users[curSelection].sectionName.length > 1)
		{
			var textValue = credData.users[curSelection].sectionName;
			if (credData.users[curSelection].sectionName == null)
				textValue = "";
			rightMarker.text = textValue;
		}

		if (credData.tweenColor)
		{
			var color:FlxColor = FlxColor.fromRGB(credData.users[curSelection].colors[0], credData.users[curSelection].colors[1],
				credData.users[curSelection].colors[2]);

			if (menuColorTween != null)
				menuColorTween.cancel();

			if (color != menuBG.color)
			{
				menuColorTween = FlxTween.color(menuBG, 0.35, menuBG.color, color, {
					onComplete: function(tween:FlxTween) menuColorTween = null
				});
			}
		}

		// reset social;
		curSocial = 0;
		updateSocial(0, false);
	}

	public function updateBottomMarker()
	{
		var textData = credData.users[curSelection].textData;
		var fullText:String = '';

		// description
		if (textData[0] != null && textData[0].length >= 1)
			fullText += textData[0];

		// quotes
		if (textData[1] != null && textData[1].length >= 1)
			fullText += ' - "' + textData[1] + '"';

		bottomMarker.text = fullText;
	}

	public function updateSocial(huh:Int = 0, playSound:Bool = true) // HUH???
	{
		if (credData.users[curSelection].urlData[curSocial][0] == null)
			return;

		// prevent loud scroll sounds
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSocial += huh;
		if (curSocial < 0)
			curSocial = credData.users[curSelection].urlData[0].length - 1;
		if (curSocial >= credData.users[curSelection].urlData.length)
			curSocial = 0;

		if (credData.users[curSelection].urlData[curSocial][0] != null)
		{
			var textValue = '< ' + credData.users[curSelection].urlData[curSocial][0] + ' >';
			if (credData.users[curSelection].urlData[curSocial][0] == null)
				textValue = "";
			centerMarker.text = textValue;
		}
	}
}