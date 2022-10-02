package states.editors;

import base.MusicBeat.MusicBeatState;
import dependency.Discord;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.animation.FlxAnimation;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import funkin.Character;
import funkin.Stage;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import states.editors.data.PsychDropDown;
import states.menus.FreeplayMenuState;

using StringTools;

/**
	character offset editor
	this is just code from the base game
	with some tweaking here and there to make it work on forever engine
	and some other additional features
 */
class CharacterOffsetEditor extends MusicBeatState
{
	var _file:FileReference;

	// characters
	var char:Character;
	var ghost:Character;

	var curCharacter:String;
	var curGhost:String;

	var isPlayer:Bool = false;

	var curAnim:Int = 0;

	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];

	var ghostAnimList:Array<String> = [''];

	var camFollow:FlxObject;

	var stageBuild:Stage;
	var curStage:String = 'stage';

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var UI_box:FlxUITabMenu;

	public function new(curCharacter:String, isPlayer:Bool = false, curStage:String)
	{
		super();
		curGhost = curCharacter;
		this.curCharacter = curCharacter;
		this.isPlayer = isPlayer;
		this.curStage = curStage;
	}

	override public function create()
	{
		super.create();

		FlxG.sound.music.stop();
		FlxG.mouse.visible = true;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// set up camFollow
		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		// add stage
		stageBuild = new Stage(curStage);
		add(stageBuild);

		generateGhost(!curCharacter.startsWith('bf'));
		generateCharacter(!curCharacter.startsWith('bf'));

		// add texts
		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
		add(textAnim);

		genCharOffsets();

		#if DISCORD_RPC
		Discord.changePresence('OFFSET EDITOR', 'Editing: ' + curCharacter);
		#end

		// add menu tabs
		var tabs = [
			{name: 'Preferences', label: 'Preferences'},
			{name: 'Characters', label: 'Characters'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.cameras = [camHUD];
		UI_box.resize(250, 125);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);

		addPreferencesUI();
		addCharactersUI();
	}

	var ghostAnimDropDown:PsychDropDown;
	var check_offset:FlxUICheckBox;

	function addPreferencesUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Preferences";

		check_offset = new FlxUICheckBox(10, 60, null, null, "Offset Mode", 100);
		check_offset.checked = true;

		var saveButton:FlxButton = new FlxButton(140, 30, "Save", function()
		{
			saveCharOffsets();
		});

		ghostAnimDropDown = new PsychDropDown(10, 30, PsychDropDown.makeStrIdLabelArray(ghostAnimList, true), function(animation:String)
		{
			if (ghostAnimList[0] != '' || ghostAnimList[0] != null)
				ghost.playAnim(ghostAnimList[Std.parseInt(animation)], true);
		});

		tab_group.add(new FlxText(ghostAnimDropDown.x, ghostAnimDropDown.y - 18, 0, 'Ghost Animation:'));
		tab_group.add(check_offset);
		tab_group.add(ghostAnimDropDown);
		tab_group.add(saveButton);
		UI_box.addGroup(tab_group);
	}

	var showGhost:Bool = false;
	var followCharOffset:Bool = true;

	var showGhostBttn:FlxButton;
	var followCharOffsetBttn:FlxButton;

	function addCharactersUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Characters";

		var characters:Array<String> = CoolUtil.returnAssetsLibrary('characters', 'assets');

		var resetBttn:FlxButton = new FlxButton(140, 30, "Reset Offsets", function()
		{
			var prevStage = curStage;
			var prevCharacter = curCharacter;
			Main.switchState(this, new CharacterOffsetEditor(prevCharacter, !prevCharacter.startsWith('bf'), curStage));
		});

		showGhostBttn = new FlxButton(140, 50, "Show Ghost", function()
		{
			if (!showGhost)
			{
				ghost.visible = true;
				showGhostBttn.text = 'Hide Ghost';
				showGhost = true;
			}
			else
			{
				ghost.visible = false;
				showGhostBttn.text = 'Show Ghost';
				showGhost = false;
			}
		});

		followCharOffsetBttn = new FlxButton(140, 70, "Follow: ON", function()
		{
			if (followCharOffset)
			{
				followCharOffset = false;
				followCharOffsetBttn.text = 'Follow: OFF';
			}
			else
			{
				followCharOffset = true;
				followCharOffsetBttn.text = 'Follow: ON';
			}
		});

		var characterDropDown = new PsychDropDown(10, 30, PsychDropDown.makeStrIdLabelArray(characters, true), function(character:String)
		{
			curCharacter = characters[Std.parseInt(character)];
			generateCharacter(!curCharacter.startsWith('bf'));
			genCharOffsets(true, false);
		});
		characterDropDown.selectedLabel = curCharacter;

		var ghostCharacterDropDown = new PsychDropDown(10, characterDropDown.y + 40, PsychDropDown.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				curGhost = characters[Std.parseInt(character)];
				generateGhost(!curCharacter.startsWith('bf'));
				genCharOffsets(false, true);
			});
		ghostCharacterDropDown.selectedLabel = curGhost;

		tab_group.add(resetBttn);
		tab_group.add(showGhostBttn);
		tab_group.add(followCharOffsetBttn);

		tab_group.add(new FlxText(ghostCharacterDropDown.x, ghostCharacterDropDown.y - 18, 0, 'Ghost Character:'));
		tab_group.add(ghostCharacterDropDown);
		tab_group.add(new FlxText(characterDropDown.x, characterDropDown.y - 18, 0, 'Character:'));
		tab_group.add(characterDropDown);

		UI_box.addGroup(tab_group);
	}

	override function update(elapsed:Float)
	{
		MusicBeatState.camBeat = camHUD;
		textAnim.text = (char.animation.curAnim.name != null ? char.animation.curAnim.name : '');
		ghost.flipX = char.flipX;

		ghost.visible = showGhost;
		char.alpha = (ghost.visible ? 0.85 : 1);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			Main.switchState(this, new PlayState());
		}

		if (FlxG.keys.justPressed.BACKSPACE)
		{
			FlxG.mouse.visible = false;
			Main.switchState(this, new FreeplayMenuState());
		}

		// camera controls
		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1;
		}

		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			var addToCam:Float = 500 * elapsed;
			if (FlxG.keys.pressed.SHIFT)
				addToCam *= 4;

			if (FlxG.keys.pressed.I)
				camFollow.y -= addToCam;
			else if (FlxG.keys.pressed.K)
				camFollow.y += addToCam;

			if (FlxG.keys.pressed.J)
				camFollow.x -= addToCam;
			else if (FlxG.keys.pressed.L)
				camFollow.x += addToCam;
		}

		// character controls
		if (FlxG.keys.justPressed.F)
		{
			char.flipX = !char.flipX;
		}

		if (FlxG.keys.justPressed.W)
			updateAnimation(-1);
		if (FlxG.keys.justPressed.S)
			updateAnimation(1);

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);
		}

		if (check_offset.checked && char.animation.curAnim != null)
		{
			var controlArray:Array<Bool> = [
				FlxG.keys.justPressed.LEFT,
				FlxG.keys.justPressed.RIGHT,
				FlxG.keys.justPressed.UP,
				FlxG.keys.justPressed.DOWN
			];

			for (i in 0...controlArray.length)
			{
				if (controlArray[i])
				{
					var holdShift = FlxG.keys.pressed.SHIFT;
					var multiplier = 1;
					if (holdShift)
						multiplier = 10;

					var arrayVal = 0;
					if (i > 1)
						arrayVal = 1;

					var negaMult:Int = 1;
					if (i % 2 == 1)
						negaMult = -1;
					char.animOffsets.get(animList[curAnim])[arrayVal] += negaMult * multiplier;

					updateTexts();
					genCharOffsets(false);
					char.playAnim(animList[curAnim], false);
					if (ghost.animation.curAnim != null
						&& char.animation.curAnim != null
						&& char.animation.curAnim.name == ghost.animation.curAnim.name)
					{
						ghost.playAnim(char.animation.curAnim.name, false);
					}
				}
			}
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveCharOffsets();

		if (followCharOffset)
			ghost.setPosition(char.x, char.y);

		super.update(elapsed);
	}

	function updateAnimation(hey:Int)
	{
		curAnim += hey;

		if (curAnim < 0)
			curAnim = animList.length - 1;
		if (curAnim >= animList.length)
			curAnim = 0;
	}

	function generateCharacter(isDad:Bool = true)
	{
		var genOffset:Array<Int> = [100, 100];

		if (!isDad)
			genOffset = [770, 450];

		if (curCharacter.startsWith('gf'))
			genOffset = [300, 100];

		remove(char);
		char = new Character(0, 0, !isDad, curCharacter);
		char.setPosition(genOffset[0], genOffset[1]);
		char.debugMode = true;
		add(char);
	}

	function generateGhost(isDad:Bool = true)
	{
		var genOffset:Array<Int> = [100, 100];

		if (!isDad)
			genOffset = [770, 450];

		if (curGhost.startsWith('gf'))
			genOffset = [300, 100];

		remove(ghost);
		ghost = new Character(0, 0, !isDad, curGhost);
		ghost.setPosition(genOffset[0], genOffset[1]);
		ghost.debugMode = true;
		ghost.visible = false;
		ghost.color = 0xFF666688;
		add(ghost);
	}

	function genCharOffsets(pushList:Bool = true, pushGhostList:Bool = true):Void
	{
		var daLoop:Int = 0;

		var i:Int = dumbTexts.members.length - 1;
		while (i >= 0)
		{
			var memb:FlxText = dumbTexts.members[i];
			if (memb != null)
			{
				memb.kill();
				dumbTexts.remove(memb);
				memb.destroy();
			}
			--i;
		}
		dumbTexts.clear();

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			text.scrollFactor.set();
			text.cameras = [camHUD];
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			if (pushGhostList)
				ghostAnimList.push(anim);

			daLoop++;
		}

		textAnim.visible = true;
		if (dumbTexts.length < 1)
		{
			animList = ['[ERROR]'];

			var text:FlxText = new FlxText(10, 38, 0, '
				No animations found
				\nplease make sure your ${curCharacter}.hx script
				has the offsets properly set up
				\n\nTry: addOffset(\'animationName\', xPosition, yPosition);
				', 15);
			text.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			text.scrollFactor.set();
			text.color = FlxColor.RED;
			text.cameras = [camHUD];
			dumbTexts.add(text);

			textAnim.visible = false;
		}
	}

	function saveCharOffsets():Void
	{
		var result = "";

		for (anim => offsets in char.animOffsets)
		{
			var text = 'addOffset("' + anim + '", ' + offsets.join(", ") + ');';
			result += text + "\n";
		}

		if ((result != null) && (result.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(result.trim(), curCharacter + "Offsets.hx");
		}
	}

	/**
	 * Called when the save file dialog is completed.
	 */
	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved OFFSET DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the offset data.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Offset data");
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}
}
