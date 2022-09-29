package states.editors;

import haxe.Json;
import base.*;
import base.Conductor.BPMChangeEvent;
import base.CoolUtil;
import base.MusicBeat.MusicBeatState;
import base.SongLoader.LegacySection;
import base.SongLoader.LegacySong;
import base.SongLoader.Song;
import dependency.AbsoluteText.EventText;
import dependency.Discord;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import funkin.*;
import funkin.Strumline.UIStaticArrow;
import funkin.ui.*;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import states.editors.data.*;
import states.menus.FreeplayState;

using StringTools;

/**
	In case you dont like the forever engine chart editor, here's the base game one instead.
**/
class OriginalChartEditor extends MusicBeatState
{
	var _file:FileReference;
	var _diff:String = '';

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	var curNoteType:Int = 0;

	var curNoteName:Array<String> = ['Normal Note', 'Alt Animation', 'Hey!', 'Mine Note', 'GF Note', 'No Animation'];

	// event name - desciption
	var eventArray:Array<Dynamic> = [
		["", ""],
		[
			"Hey!",
			"Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"
		],
		[
			"Set GF Speed",
			"Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"
		],
		[
			"Change Character",
			"Sets the current Character to a new one\nValue 1: Character to change (dad, bf, gf)\nValue 2: New character's name"
		],
		[
			"Play Animation",
			"Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"
		]
	];

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;

	var CAM_OFFSET:Int = 360;

	var dummyArrow:FlxSprite;

	public static var songPosition:Float = 0;
	public static var curSong:LegacySong;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var curRenderedEvents:FlxTypedGroup<EventNote> = new FlxTypedGroup<EventNote>();
	var curRenderedTexts:FlxTypedGroup<EventText> = new FlxTypedGroup<EventText>();

	var gridBG:FlxSprite;
	var gridMult:Int = 2;

	var firstBlackLine:FlxSprite;
	var secondBlackLine:FlxSprite;

	var _song:LegacySong;

	var typingShit:FlxInputText;
	/*
	 * an array with an Note's data, like Hold Length, Type, etc
	 * represents the current selected or last placed note
	**/
	var curSelectedNote:Array<Dynamic>;

	/**
	 * an array with an Event's Data
	 * similar to `curSelectedNote`, it stores data from said event
	 * such as values or timing to hit the note
	 */
	var curSelectedEvent:Array<Dynamic>;

	var gridGroup:FlxTypedGroup<FlxObject>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	// was annoying.
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	var blockPressWhileScrolling:Array<PsychDropDown> = [];

	override function create()
	{
		super.create();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
			addSection();

		curSection = lastSection;

		#if DISCORD_RPC
		Discord.changePresence('CHART EDITOR', 'Charting: ' + _song.song + ' [${CoolUtil.difficultyFromString()}] - by ' + _song.author, null, null, null,
			true);
		#end

		gridGroup = new FlxTypedGroup<FlxObject>();
		add(gridGroup);

		generateGrid();

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		generateHeads();
		updateHeads();

		tempBpm = _song.bpm;

		addSection();
		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs:Array<{name:String, label:String}> = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Notes", label: 'Notes'},
			{name: "Events", label: 'Events'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + GRID_SIZE / 2;
		UI_box.y = 25;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addEventsUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedEvents);
		add(curRenderedTexts);

		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
	}

	var stepperSpeed:FlxUINumericStepper;
	var stepperBPM:FlxUINumericStepper;

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;
		blockPressWhileTypingOn.push(UI_songTitle);

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			#if DEBUG_TRACES trace('CHECKED!'); #end
		};

		var check_mute_inst = new FlxUICheckBox(10, 335, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			songMusic.volume = vol;
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if (vocals != null)
			{
				var vol:Float = 1;

				if (check_mute_vocals.checked)
					vol = 0;

				vocals.volume = vol;
			}
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			pauseMusic();
			saveLevel();
		});

		var saveEvent:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, 'Save Events', function()
		{
			pauseMusic();
			saveEvents();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			pauseMusic();
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			pauseMusic();
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		stepperSpeed = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressWhileTypingOnStepper.push(stepperSpeed);

		stepperBPM = new FlxUINumericStepper(10, 65, 1, 1, 1, 350, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);

		var baseChars:Array<String> = CoolUtil.returnAssetsLibrary('characters', 'assets');
		var baseStages:Array<String> = CoolUtil.returnAssetsLibrary('stages', 'assets');
		var baseAssets:Array<String> = CoolUtil.returnAssetsLibrary('UI/default', 'assets/images');

		var characters:Array<String> = baseChars;

		var player1DropDown = new PsychDropDown(10, stepperSpeed.y + 45, PsychDropDown.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player1DropDown.selectedLabel = _song.player1;
		blockPressWhileScrolling.push(player1DropDown);

		var gfVersionDropDown = new PsychDropDown(player1DropDown.x, player1DropDown.y + 40, PsychDropDown.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.gfVersion = characters[Std.parseInt(character)];
				updateHeads();
			});
		gfVersionDropDown.selectedLabel = _song.gfVersion;
		blockPressWhileScrolling.push(gfVersionDropDown);

		var player2DropDown = new PsychDropDown(player1DropDown.x, gfVersionDropDown.y + 40, PsychDropDown.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.player2 = characters[Std.parseInt(character)];
				updateHeads();
			});
		player2DropDown.selectedLabel = _song.player2;
		blockPressWhileScrolling.push(player2DropDown);

		var stages:Array<String> = baseStages;

		var stageDropDown = new PsychDropDown(player1DropDown.x + 140, player1DropDown.y, PsychDropDown.makeStrIdLabelArray(stages, true),
			function(stage:String)
			{
				_song.stage = stages[Std.parseInt(stage)];
			});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		var assetModifiers:Array<String> = baseAssets;

		var assetModifierDropDown = new PsychDropDown(stageDropDown.x, gfVersionDropDown.y, PsychDropDown.makeStrIdLabelArray(assetModifiers, true),
			function(asset:String)
			{
				_song.assetModifier = assetModifiers[Std.parseInt(asset)];
			});
		assetModifierDropDown.selectedLabel = _song.assetModifier;
		blockPressWhileScrolling.push(assetModifierDropDown);

		if (CoolUtil.difficulties[PlayState.storyDifficulty].toLowerCase() != 'normal')
			_diff = '-' + CoolUtil.difficulties[PlayState.storyDifficulty].toLowerCase();

		var difficultyDropDown = new PsychDropDown(assetModifierDropDown.x, assetModifierDropDown.y + 40,
			PsychDropDown.makeStrIdLabelArray(CoolUtil.difficulties, true), function(difficulty:String)
		{
			var newDifficulty:String = CoolUtil.difficulties[Std.parseInt(difficulty)].toLowerCase();
			trace("Current difficulty: " + CoolUtil.difficulties[PlayState.storyDifficulty]);
			trace("New diffculty: " + newDifficulty);
			PlayState.storyDifficulty = Std.parseInt(difficulty);
			if (newDifficulty != 'normal')
				_diff = '-' + newDifficulty;
			try // doing this to avoid crashes with songs that don't have 3 difficulties until I actually manage to make a custom difficulty system
			{
				PlayState.SONG = Song.loadSong(_song.song.toLowerCase() + _diff, _song.song.toLowerCase());
			}
			catch (e)
			{
				PlayState.SONG = Song.loadSong(_song.song.toLowerCase(), _song.song.toLowerCase());
			}
			Main.switchState(this, new OriginalChartEditor());
		});
		difficultyDropDown.selectedLabel = CoolUtil.difficulties[PlayState.storyDifficulty];
		blockPressWhileScrolling.push(difficultyDropDown);

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vocals);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvent);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(gfVersionDropDown.x, gfVersionDropDown.y - 15, 0, 'Girlfriend:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));
		tab_group_song.add(new FlxText(difficultyDropDown.x, difficultyDropDown.y - 15, 0, 'Difficulty:'));
		tab_group_song.add(new FlxText(assetModifierDropDown.x, assetModifierDropDown.y - 15, 0, 'Asset Skin:'));
		tab_group_song.add(player2DropDown);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(difficultyDropDown);
		tab_group_song.add(assetModifierDropDown);
		tab_group_song.add(stageDropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(camPos);
	}

	var stepperBeats:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var check_gfSec:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperBeats = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperBeats.value = getSectionBeats();
		stepperBeats.name = "section_beats";
		blockPressWhileTypingOnStepper.push(stepperBeats);

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		blockPressWhileTypingOnStepper.push(stepperSectionBPM);

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear section", function()
		{
			_song.notes[curSection].sectionNotes = [];
			updateGrid();
			updateNoteUI();
		});

		var clearNotesButton:FlxButton = new FlxButton(100, 150, "Clear notes", function()
		{
			for (sec in 0..._song.notes.length)
			{
				_song.notes[sec].sectionNotes = [];
			}
			updateGrid();
			updateNoteUI();
		});
		clearNotesButton.color = FlxColor.RED;
		clearNotesButton.label.color = FlxColor.WHITE;

		var clearEventsButton:FlxButton = new FlxButton(100, 170, "Clear events", function()
		{
			for (sec in 0..._song.notes.length)
			{
				_song.events = [];
			}
			updateGrid();
			updateEventUI();
		});
		clearEventsButton.color = FlxColor.RED;
		clearEventsButton.label.color = FlxColor.WHITE;

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];

				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
				updateHeads();
			}
		});

		// NOTE: make this a drop down later so we can make the camera point to GF.
		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation Section", 100);
		check_altAnim.name = 'check_altAnim';

		check_gfSec = new FlxUICheckBox(160, 400, null, null, "Girlfriend Section", 100);
		check_gfSec.name = 'check_gfSec';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperBeats);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_gfSec);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(clearNotesButton);
		tab_group_section.add(clearEventsButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var eventVal1Input:FlxUIInputText;
	var eventVal2Input:FlxUIInputText;
	var eventDropDown:PsychDropDown;
	var descText:FlxText;

	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		descText = new FlxText(20, 200, 0, eventArray[0][0]);

		var leEvents:Array<String> = [];
		for (i in 0...eventArray.length)
		{
			leEvents.push(eventArray[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new PsychDropDown(20, 50, PsychDropDown.makeStrIdLabelArray(leEvents, true), function(pressed:String)
		{
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = eventArray[selectedEvent][1];
			if (curSelectedEvent != null)
			{
				curSelectedEvent[1] = eventArray[selectedEvent][0];
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		eventVal1Input = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(eventVal1Input);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		eventVal2Input = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(eventVal2Input);

		tab_group_event.add(descText);
		tab_group_event.add(eventVal1Input);
		tab_group_event.add(eventVal2Input);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperSoundTest:FlxUINumericStepper;
	var strumTimeInput:FlxUIInputText;
	var noteTypeDropDown:PsychDropDown;
	var playTicksBf:FlxUICheckBox;
	var playTicksDad:FlxUICheckBox;
	var metronomeTick:FlxUICheckBox;
	var key:Int = 0;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Notes';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);

		strumTimeInput = new FlxUIInputText(10, 65, 180, "0");
		tab_group_note.add(strumTimeInput);
		blockPressWhileTypingOn.push(strumTimeInput);

		stepperSoundTest = new FlxUINumericStepper(120, 25, 1, _song.bpm, 1, 350, 0);
		blockPressWhileTypingOnStepper.push(stepperSoundTest);

		// note types
		for (i in 0...curNoteName.length)
		{
			curNoteName[i] = i + '. ' + curNoteName[i];
		}
		noteTypeDropDown = new PsychDropDown(10, 105, PsychDropDown.makeStrIdLabelArray(curNoteName, false), function(type:String)
		{
			curNoteType = Std.parseInt(type);
			if (curSelectedNote != null && curSelectedNote[1] > -1)
			{
				curSelectedNote[3] = curNoteType;
				updateGrid();
			}
		});

		blockPressWhileScrolling.push(noteTypeDropDown);

		metronomeTick = new FlxUICheckBox(10, 305, null, null, 'Enable Metronome', 100);
		metronomeTick.checked = false;

		playTicksBf = new FlxUICheckBox(10, 335, null, null, 'Play Hitsounds (Boyfriend - in editor)', 100);
		playTicksBf.checked = false;

		playTicksDad = new FlxUICheckBox(playTicksBf.x + 120, playTicksBf.y, null, null, 'Play Hitsounds (Opponent - in editor)', 100);
		playTicksDad.checked = false;

		tab_group_note.add(new FlxText(10, 10, 0, 'Sustain length:'));
		tab_group_note.add(new FlxText(120, 10, 0, 'Metronome BPM:'));
		tab_group_note.add(new FlxText(10, 50, 0, 'Strum time (in miliseconds):'));
		tab_group_note.add(new FlxText(10, 90, 0, 'Note Type:'));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(strumTimeInput);
		tab_group_note.add(noteTypeDropDown);
		tab_group_note.add(playTicksBf);
		tab_group_note.add(playTicksDad);
		tab_group_note.add(stepperSoundTest);
		tab_group_note.add(metronomeTick);

		UI_box.addGroup(tab_group_note);
		// I'm genuinely tempted to go around and remove every instance of the word "sus" it is genuinely killing me inside
	}

	var songMusic:FlxSound;

	function loadSong(daSong:String):Void
	{
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		songMusic = new FlxSound();
		vocals = new FlxSound();

		songMusic.loadEmbedded(Paths.songSounds(daSong, 'Inst'), false, true);

		if (_song.needsVoices)
			vocals.loadEmbedded(Paths.songSounds(daSong, 'Voices'), false, true);

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		vocals.play();

		curSong = _song;
		if (curSong == _song)
			songMusic.time = songPosition * songMusic.pitch;

		pauseMusic();

		songMusic.onComplete = function()
		{
			ForeverTools.killMusic([songMusic, vocals]);
			loadSong(daSong);
			changeSection();
			songPosition = 0;
			songMusic.time = 0;
		};
		//
	}

	function pauseMusic()
	{
		songMusic.time = Math.max(songMusic.time, 0);
		songMusic.time = Math.min(songMusic.time, songMusic.length);

		songMusic.pause();
		vocals.pause();
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation Section":
					_song.notes[curSection].altAnim = check.checked;
				case "Girlfriend Section":
					_song.notes[curSection].gfSection = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			// ew what was this before? made it switch cases instead of else if
			switch (wname)
			{
				case 'section_beats':
					_song.notes[curSection].sectionBeats = nums.value; // change length
					updateGrid(); // vrrrrmmm
				case 'song_speed':
					_song.speed = nums.value; // change the song speed
				case 'song_bpm':
					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));
				case 'note_susLength': // STOP POSTING ABOUT AMONG US
					curSelectedNote[2] = nums.value; // change the currently selected note's length
					updateGrid(); // oh btw I know sus stands for sustain it just bothers me
				case 'note_type':
					curNoteType = Std.int(nums.value);
				case 'section_bpm':
					_song.notes[curSection].bpm = Std.int(nums.value); // redefine the section's bpm
					updateGrid(); // update the note grid
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			switch (sender)
			{
				case strumTimeInput:
					if (curSelectedNote != null)
					{
						var value:Float = Std.parseFloat(strumTimeInput.text);
						if (Math.isNaN(value))
							value = 0;
						curSelectedNote[0] = value;
						updateGrid();
					}
			}

			// had to do it like this or else it would tell me that the case would go unused
			if (sender == eventVal1Input)
			{
				if (curSelectedEvent != null)
				{
					curSelectedEvent[2] = eventVal1Input.text;
					updateGrid();
					updateEventUI();
				}
			}
			else if (sender == eventVal2Input)
			{
				if (curSelectedEvent != null)
				{
					curSelectedEvent[3] = eventVal2Input.text;
					updateGrid();
					updateEventUI();
				}
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection + add)
		{
			if (_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	var lastSongPos:Null<Float> = null;

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = songMusic.time;

		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * 16)) / (getSectionBeats() / 4);
		camPos.y = strumLine.y;

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			// trace(curStep);
			// trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			// trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		FlxG.watch.addQuick('daDecBeat', decBeat);
		FlxG.watch.addQuick('daDecStep', decStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							#if DEBUG_TRACES trace('tryin to delete note...'); #end
							deleteNote(note);
						}
					}
				});
			}
			else if (FlxG.mouse.overlaps(curRenderedEvents))
			{
				curRenderedEvents.forEach(function(event:EventNote)
				{
					if (FlxG.mouse.overlaps(event))
					{
						if (FlxG.keys.pressed.CONTROL)
							selectEvent(event);
						else
							deleteEvent(event);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4))
				{
					if (Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE) > -1)
					{
						FlxG.log.add('added note');
						addNote();
					}
					else
					{
						FlxG.log.add('added event');
						addEvent();
					}
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn)
		{
			if (inputText.hasFocus)
			{
				blockInput = true;
				break;
			}
		}

		if (!blockInput)
		{
			for (stepper in blockPressWhileTypingOnStepper)
			{
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if (leText.hasFocus)
				{
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			for (dropDownMenu in blockPressWhileScrolling)
			{
				if (dropDownMenu.dropPanel.visible)
				{
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				bpmTxt.visible = !bpmTxt.visible;
			}
			if (FlxG.keys.justPressed.ENTER)
				saveAndClose('PlayState');
			else if (FlxG.keys.justPressed.BACKSPACE)
				saveAndClose('FreeplayState');

			if (FlxG.keys.justPressed.E)
			{
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q)
			{
				changeNoteSustain(-Conductor.stepCrochet);
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}

			if (!typingShit.hasFocus)
			{
				if (FlxG.keys.justPressed.SPACE)
				{
					if (songMusic.playing)
					{
						songMusic.pause();
						vocals.pause();
					}
					else
					{
						vocals.play();
						songMusic.play();
					}
				}

				if (FlxG.keys.justPressed.R)
				{
					if (FlxG.keys.pressed.SHIFT)
						resetSection(true);
					else
						resetSection();
				}

				if (FlxG.mouse.wheel != 0)
				{
					songMusic.pause();
					vocals.pause();

					songMusic.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
					vocals.time = songMusic.time;
				}

				if (!FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
					{
						songMusic.pause();
						vocals.pause();

						var daTime:Float = 700 * FlxG.elapsed;

						if (FlxG.keys.pressed.W)
						{
							songMusic.time -= daTime;
						}
						else
							songMusic.time += daTime;

						vocals.time = songMusic.time;
					}
				}
				else
				{
					if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
					{
						songMusic.pause();
						vocals.pause();

						var daTime:Float = Conductor.stepCrochet * 2;

						if (FlxG.keys.justPressed.W)
						{
							songMusic.time -= daTime;
						}
						else
							songMusic.time += daTime;

						vocals.time = songMusic.time;
					}
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		if (songMusic.time < 0)
		{
			songMusic.pause();
			songMusic.time = 0;
		}
		else if (songMusic.time > songMusic.length)
		{
			songMusic.pause();
			songMusic.time = 0;
			changeSection();
		}

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.Z)
		{
			songMusic.pitch += 0.1;
			vocals.pitch += 0.1;
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.X)
		{
			songMusic.pitch -= 0.1;
			vocals.pitch -= 0.1;
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.C)
		{
			songMusic.pitch = 1;
			vocals.pitch = 1;
		}

		if (songMusic.pitch >= 6)
		{
			songMusic.pitch = 6;
			vocals.pitch = 6;
		}

		if (songMusic.pitch <= 0.1)
		{
			songMusic.pitch = 0.1;
			vocals.pitch = 0.1;
		}

		bpmTxt.text = 'Song: ${_song.song}'
			+ '\nDiff: ${_diff.replace('-', '')}'
			+ '\n'
			+ Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(songMusic.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nBeat: "
			+ curBeat
			+ "\nStep: "
			+ curStep
			+ "\nRate: "
			+ songMusic.pitch;
		super.update(elapsed);

		if (metronomeTick.checked && lastSongPos != Conductor.songPosition)
		{
			var soundInterval:Float = 60 / stepperSoundTest.value;
			var metronomeCurStep:Int = Math.floor(((Conductor.songPosition + stepperSoundTest.value) / soundInterval) / 1000);
			var lastStepHit:Int = Math.floor(((lastSongPos + stepperSoundTest.value) / soundInterval) / 1000);
			if (metronomeCurStep != lastStepHit)
			{
				FlxG.sound.play(Paths.sound('soundTest'));
			}
		}

		var playedSound:Array<Bool> = [];
		for (i in 0...8)
		{
			playedSound.push(false);
		}

		// each alive rendered note on the current sections;
		curRenderedNotes.forEachAlive(function(note:Note)
		{
			if ((note.strumTime < songMusic.time))
			{
				var data:Int = note.noteData % 4;

				// check if the song is playing and if the sound was not played once;
				if (songMusic.playing && !playedSound[data] && note.noteData > -1 && note.strumTime >= lastSongPos)
				{
					if ((playTicksBf.checked) && (note.mustPress) || (playTicksDad.checked) && (!note.mustPress))
					{
						FlxG.sound.play(Paths.sound('hitsounds/${Init.getSetting('Hitsound Type').toLowerCase()}/hit'));
						playedSound[data] = true;
					}
				}
			}
		});

		lastSongPos = Conductor.songPosition;
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function saveAndClose(State:String)
	{
		autosaveSong();
		lastSection = curSection;
		// CoolUtil.difficulties = CoolUtil.baseDifficulties;

		PlayState.SONG = _song;
		ForeverTools.killMusic([songMusic, vocals]);

		FlxG.mouse.visible = false;

		if (State == 'PlayState')
		{
			Main.switchState(this, new PlayState());
		}
		else
		{
			PlayState.chartingMode = false;
			Main.switchState(this, new FreeplayState());
		}
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (songMusic.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((songMusic.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		songMusic.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		songMusic.time = sectionStartTime();

		if (songBeginning)
		{
			songMusic.time = 0;
			curSection = 0;
		}

		vocals.time = songMusic.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
		updateHeads();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				songMusic.pause();

				songMusic.time = sectionStartTime();
				if (vocals != null)
				{
					vocals.pause();
					vocals.time = songMusic.time;
				}
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
			updateHeads();
		}
		else
		{
			changeSection();
			updateHeads();
		}
		Conductor.songPosition = songMusic.time;
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperBeats.value = getSectionBeats();
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_gfSec.checked = sec.gfSection;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function generateHeads()
	{
		// stupid.
		var bf:Character = new Character(0, 0, _song.player1);
		var dad:Character = new Character(0, 0, _song.player2);

		var eventIcon:FlxSprite = new FlxSprite(-GRID_SIZE - 5, -90);
		eventIcon.loadGraphic(Paths.image(ForeverTools.returnSkin('eventNote', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		leftIcon = new HealthIcon(bf.icon);
		rightIcon = new HealthIcon(dad.icon);

		eventIcon.scrollFactor.set(1, 1);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		eventIcon.setGraphicSize(30, 30);
		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(eventIcon);
		add(leftIcon);
		add(rightIcon);
	}

	function updateHeads():Void
	{
		if (!_song.notes[curSection].mustHitSection)
		{
			leftIcon.setPosition(gridBG.width / 2, -100);
			rightIcon.setPosition(0, -100);
		}
		else
		{
			leftIcon.setPosition(0, -100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[1] > -1)
			{
				stepperSusLength.value = curSelectedNote[2];
				if (curSelectedNote[3] != null)
				{
					curNoteType = Std.parseInt(noteTypeDropDown.selectedLabel);
					noteTypeDropDown.selectedLabel = (curNoteType <= 0 ? '' : curNoteType + '. ' + curNoteName[curNoteType]);
				}
				strumTimeInput.text = curSelectedNote[0];
			}
		}
	}

	function updateEventUI()
	{
		if (curSelectedEvent == null)
			return;

		eventDropDown.selectedLabel = curSelectedEvent[1];
		var selected:Int = Std.parseInt(eventDropDown.selectedId);
		descText.text = eventArray[selected][1];
		eventVal1Input.text = curSelectedEvent[2];
		eventVal2Input.text = curSelectedEvent[3];
	}

	function generateGrid()
	{
		gridGroup.clear();

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, Std.int(GRID_SIZE * 32));
		gridGroup.add(gridBG);

		var gridBlack:FlxSprite = new FlxSprite(0, gridBG.height / 2).makeGraphic(Std.int(GRID_SIZE * 9), Std.int(gridBG.height / 2), FlxColor.BLACK);
		gridBlack.alpha = 0.4;
		gridGroup.add(gridBlack);

		firstBlackLine = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridGroup.add(firstBlackLine);

		secondBlackLine = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridGroup.add(secondBlackLine);
	}

	final function updateGrid():Void
	{
		curRenderedNotes.clear();
		curRenderedSustains.clear();
		curRenderedEvents.clear();
		curRenderedTexts.clear();

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daStrumTime = i[0];
			var daNoteInfo = i[1];
			var daSus = i[2];
			var daNoteType:Int = i[3];

			#if DEBUG_TRACES trace('Current note type is ' + curNoteName[daNoteType] + '.'); #end

			var note:Note = ForeverAssets.generateArrow(_song.assetModifier, daStrumTime, daNoteInfo % 4, 0, null, null, daNoteType);
			note.sustainLength = daSus;
			note.noteType = daNoteType;

			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.x = Math.floor(daNoteInfo * GRID_SIZE) + GRID_SIZE;
			note.y = getYfromStrumNotes(daStrumTime - sectionStartTime(), getSectionBeats());
			note.updateHitbox();
			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var colorList:Array<Int> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
				if (_song.assetModifier == 'pixel')
					colorList = [0xFFE276FF, 0xFF3DCAFF, 0xFF71E300, 0xFFFF884E];

				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2 - 3),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, (gridBG.height / gridMult))),
						colorList[note.noteData]);
				curRenderedSustains.add(sustainVis);
			}

			// attach a text to their respective notetype;
			if (daNoteType != 0)
			{
				var noteTypeNum:EventText = new EventText(0, 0, 100, Std.string(daNoteType), 24);
				noteTypeNum.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				noteTypeNum.xAdd = -32;
				noteTypeNum.yAdd = 6;
				noteTypeNum.borderSize = 1;
				curRenderedTexts.add(noteTypeNum);
				noteTypeNum.tracker = note;
			}

			note.mustPress = _song.notes[curSection].mustHitSection;
			if (i[1] > 3)
				note.mustPress = !note.mustPress;
		}

		var sectionStart:Float = sectionStartTime();
		var sectionEnd:Float = sectionStartTime(1);

		if (_song.events != null && _song.events.length > 1)
		{
			for (i in _song.events)
			{
				if (sectionEnd > i[0] && i[0] >= sectionStart)
				{
					var event:EventNote = new EventNote(i[1], i[0], i[2], i[3]);
					event.y = Math.floor(getYfromStrum((event.strumTime - sectionStartTime()) % (Conductor.stepCrochet * getSectionBeats())));
					event.setGraphicSize(GRID_SIZE, GRID_SIZE);
					event.updateHitbox();
					curRenderedEvents.add(event);

					var attachedEventTxt:EventText = new EventText(300,
						'Event: '
						+ event.event
						+ ' ('
						+ Math.floor(event.strumTime)
						+ ' ms)'
						+ '\nValue 1: '
						+ event.val1
						+ '\nValue 2: '
						+ event.val2, 12);
					attachedEventTxt.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					attachedEventTxt.xAdd = -330;
					attachedEventTxt.borderSize = 1;
					curRenderedTexts.add(attachedEventTxt);
					attachedEventTxt.tracker = event;
					event.child = attachedEventTxt;
				}
			}
		}
	}

	function addSection(sectionBeats:Float = 4):Void
	{
		var sec:LegacySection = {
			sectionBeats: sectionBeats,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			gfSection: false,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function selectEvent(event:EventNote):Void
	{
		for (i in _song.events)
			if (similarEvent(event, i))
			{
				curSelectedEvent = i;
				updateEventUI();
				updateGrid();
				break;
			}
	}

	function deleteNote(note:Note):Void
	{
		var data:Null<Int> = note.noteData;

		if (data > -1 && note.mustPress != _song.notes[curSection].mustHitSection)
			data += 4;

		if (data > -1)
		{
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] == data)
				{
					FlxG.log.add('FOUND EVIL NUMBER');
					_song.notes[curSection].sectionNotes.remove(i);
					break;
				}
			}
		}

		updateGrid();
	}

	function deleteEvent(event:EventNote):Void
	{
		for (i in _song.events)
		{
			if (i[0] == event.strumTime)
			{
				_song.events[curSection].remove(i);
				curRenderedTexts.remove(event.child);
				updateGrid();
				break;
			}
		}
	}

	function similarEvent(event:EventNote, array:Array<Dynamic>)
	{
		if (array == null)
			return false;

		return array[0] == event.strumTime;
	}

	function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE);
		var noteType = curNoteType; // define notes as the current type
		var noteSus = 0; // ninja you will NOT get away with this

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteType]);
		}

		strumTimeInput.text = curSelectedNote[0];

		updateGrid();
		updateNoteUI();
		autosaveSong();
	}

	function addEvent():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var event = eventDropDown.selectedLabel;
		var text1 = eventVal1Input.text;
		var text2 = eventVal2Input.text;

		_song.events.push([noteStrum, event, text1, text2]);
		curSelectedEvent = _song.events[_song.events.length - 1];

		updateGrid();
		updateEventUI();
	}

	function getStrumTime(yPos:Float):Float
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + (gridBG.height / gridMult) * 1, 0, 16 * Conductor.stepCrochet);

	function getYfromStrum(strumTime:Float):Float
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + (gridBG.height / gridMult) * 1);

	function getYfromStrumNotes(strumTime:Float, beats:Float):Float
	{
		var value:Float = strumTime / (beats * 4 * Conductor.stepCrochet);
		return GRID_SIZE * beats * 4 * value + gridBG.y;
	}

	/*
		function calculateSectionLengths(?sec:LegacySection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function getSectionBeats(?section:Null<Int> = null)
	{
		if (section == null)
			section = curSection;
		var val:Null<Float> = null;

		if (_song.notes[section] != null)
			val = _song.notes[section].sectionBeats;
		return val != null ? val : 4;
	}

	function loadJson(song:String):Void
	{
		try
		{
			PlayState.SONG = Song.loadSong(song.toLowerCase() + _diff, song.toLowerCase());
		}
		catch (e)
		{
			PlayState.SONG = Song.loadSong(song.toLowerCase(), song.toLowerCase());
		}
		Main.switchState(this, new OriginalChartEditor());
	}

	function autosaveSong():Void
	{
		var swag = _song;
		swag.events = null;

		var json = {
			"song": swag
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && data.length > 0)
		{
			FlxG.save.data.autosave = data;
		}
		FlxG.save.flush();
	}

	function loadAutosave():Void
	{
		try
		{
			PlayState.SONG = Song.parseSong(FlxG.save.data.autosave, null, null);
			FlxG.resetState();
		}
		catch (e)
		{
			return;
		}
	}

	function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + _diff + ".json");
		}
	}

	function saveEvents()
	{
		var json = {
			"events": _song.events
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), 'events.json');
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
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
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
