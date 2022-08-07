package states.charting;

import base.*;
import base.Conductor;
import base.MusicBeat.MusicBeatState;
import dependency.*;
import dependency.BaseButton.CoolAssButton;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import funkin.*;
import funkin.Note.NoteType;
import funkin.Song.SwagSong;
import funkin.Strumline.UIStaticArrow;
import funkin.ui.*;
import openfl.events.Event;
import openfl.geom.ColorTransform;
import states.charting.data.*;
import states.menus.FreeplayState;
import states.subStates.charting.*;

using StringTools;

/**
	As the name implies, this is the class where all of the charting state stuff happens, so when you press 7 the game
	state switches to this one, where you get to chart songs and such. I'm planning on overhauling this entirely in the future
	and making it both more practical and more user friendly.
**/
class ChartingState extends MusicBeatState
{
	var _song:SwagSong;

	var songMusic:FlxSound;
	var vocals:FlxSound;
	var keysTotal = 8;

	var strumLine:FlxSprite;

	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var strumLineCam:FlxObject;

	var currentSection:Null<Int> = 0;

	var curSelectedNote:Note;

	public static var songPosition:Float = 0;
	public static var curSong:SwagSong;

	var gridBG:FlxSprite;
	public static var gridSize:Int = 50;

	var dummyArrow:FlxSprite;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<Note>;
	var curRenderedEvents:FlxTypedGroup<EventNote>;
	var curRenderedSections:FlxTypedGroup<FlxBasic>;

	var arrowGroup:FlxTypedSpriteGroup<UIStaticArrow>;

	var buttonTextGroup:FlxTypedGroup<AbsoluteText>;
	var buttonGroup:FlxTypedGroup<CoolAssButton>;
	var gridGroup:FlxTypedGroup<FlxObject>;

	var buttonArray:Array<Array<Dynamic>> = [];

	var bfIcon:HealthIcon;
	var dadIcon:HealthIcon;

	// UI/default/forever/chart editor/quant
	var noteQuant:FNFSprite;

	var events:Array<Array<String>> = [
		//event name - desc
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
			"Change Scroll Speed", 
			"Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."
		],
		[
			"Play Animation",
			"Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"
		]
	];
	var eventTxt:FlxText;
	var currentSelectedEvent:String;

	var sustainColors:Array<Int> =
	[
		0xFFc24b99, // default note purple
		0xFF00ffff, // default note blue
		0xFF12fa05, // default note green
		0xFFf9393f, // default note red
		
		0xFFff3535, // quant red
		0xFF536bef, // quant blue
		0xFFc24b99, // quant purple
		0xFF00e550, // quant green(mint??)
		0xFF606789, // quant gray(iron, coal??, give me color names!!!)
		0xFFff7ad7, // quant pink
		0xFFffe83d, // quant yellow
		0xFFae36e6, // quant strong purple (strong purple, what???)
		0xFF0febff, // quant cyan
		0xFF606789 // quant gray(AGAIN)
	];

	override public function create()
	{
		super.create();

		generateBackground();

		Main.changeInfoAlpha(0.4);

		if (PlayState.SONG != null)
		{
			if (PlayState.SONG.events == null)
				PlayState.SONG.events = [];
		
			_song = PlayState.SONG;	
		}

		else
		{
			_song = Song.loadFromJson('test', 'test');

			if (_song.events == null)
				_song.events = [];
		}

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		#if DISCORD_RPC
		Discord.changePresence('CHART EDITOR', 'Charting: ' + _song.song + ' [${CoolUtil.difficultyFromNumber(PlayState.storyDifficulty)}] - by ' + _song.author, true);
		#end

		gridGroup = new FlxTypedGroup<FlxObject>();
		add(gridGroup);

		buttonGroup = new FlxTypedGroup<CoolAssButton>();
		add(buttonGroup);

		buttonTextGroup = new FlxTypedGroup<AbsoluteText>();
		add(buttonTextGroup);

		generateButtons();
		//generateGrid();
		
		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<Note>();
		curRenderedEvents = new FlxTypedGroup<EventNote>();
		curRenderedSections = new FlxTypedGroup<FlxBasic>();

		//generateNotes();
		recreateGrid();
		
		add(curRenderedSections);
		add(curRenderedSustains);
		add(curRenderedNotes);
		add(curRenderedEvents);

		// epic strum line
		strumLine = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width / 2), 2);
		add(strumLine);
		strumLine.screenCenter(X);

		// cursor
		dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize);
		add(dummyArrow);

		// and now the epic note thingies
		arrowGroup = new FlxTypedSpriteGroup<UIStaticArrow>(0, 0);
		for (keys in 0...keysTotal)
		{
			var typeReal:Int = 0;
			typeReal = keys;
			if (typeReal > 3)
				typeReal -= 4;

			var newArrow:UIStaticArrow = ForeverAssets.generateUIArrows(((FlxG.width / 2) - ((keysTotal / 2) * gridSize - 25)) + ((keys - 1) * gridSize), -76,
				typeReal, 'chart editor');

			newArrow.ID = keys;
			newArrow.setGraphicSize(gridSize);
			newArrow.updateHitbox();
			newArrow.alpha = 0.8;
			newArrow.antialiasing = true;

			// lol silly idiot
			newArrow.playAnim('static');

			if (newArrow.animation.curAnim.name == 'confirm')
				newArrow.alpha = 1;

			arrowGroup.add(newArrow);
		}

		add(arrowGroup);
		arrowGroup.x -= 1;

		bfIcon = new HealthIcon(_song.player1);
		dadIcon = new HealthIcon(_song.player2);
		bfIcon.scrollFactor.set(1, 1);
		dadIcon.scrollFactor.set(1, 1);

		bfIcon.setGraphicSize(gridSize, gridSize);
		dadIcon.setGraphicSize(gridSize, gridSize);

		bfIcon.flipX = true;

		add(bfIcon);
		add(dadIcon);

		bfIcon.screenCenter(X);
		dadIcon.screenCenter(X);

		dadIcon.setPosition(strumLine.width / 2, -500);
		bfIcon.setPosition(830, dadIcon.y);

		strumLineCam = new FlxObject(0, 0);
		strumLineCam.screenCenter(X);

		// code from the playstate so I can separate the camera and hud
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.camera.follow(strumLine);

		if (_song.author == null || _song.author == '')
			_song.author = '???';

		generateText();

		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = true; // Hide mouse on start
	}

	var hitSoundsPlayed:Array<Note> = [];
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		curStep = recalculateSteps();
		
		if (FlxG.keys.justPressed.SPACE)
		{
			if (songMusic.playing)
			{
				songMusic.pause();
				vocals.pause();
				// CoolUtil.difficultyFromNumber(storyDifficulty)('pause');
			}
			else
			{
				vocals.play();
				songMusic.play();

				// reset note tick sounds
				hitSoundsPlayed = [];

				// playButtonAnimation('play');
			}
		}

		if (FlxG.keys.justPressed.E && curSelectedNote != null)
			curSelectedNote.sustainLength += Conductor.stepCrochet;
		
		else if (FlxG.keys.justPressed.Q && curSelectedNote != null)
			curSelectedNote.sustainLength -= Conductor.stepCrochet;

		updateText();

		var scrollSpeed:Float = 0.75;
		if (FlxG.mouse.wheel != 0)
		{
			songMusic.pause();
			vocals.pause();

			songMusic.time = Math.max(songMusic.time - (FlxG.mouse.wheel * Conductor.stepCrochet * scrollSpeed), 0);
			songMusic.time = Math.min(songMusic.time, songMusic.length);
			vocals.time = songMusic.time;
		}

		// strumline camera stuffs!
		Conductor.songPosition = songMusic.time;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[currentSection].lengthInSteps));
		//trace(strumLine.y);
		strumLineCam.y = strumLine.y + (FlxG.height / 3);
		arrowGroup.y = strumLine.y;

		coolGradient.y = strumLineCam.y - (FlxG.height / 2);
		coolGrid.y = strumLineCam.y - (FlxG.height / 2);

		bfIcon.y = strumLineCam.y - (FlxG.height / 2);
		dadIcon.y = strumLineCam.y - (FlxG.height / 2);

		if (curBeat % 4 == 0 && curStep >= 16 * (currentSection + 1))
			changeSection(currentSection + 1, false);

		else if (strumLine.y < -15)
			changeSection(currentSection - 1, false);

		// mouse stuffs
		if (FlxG.mouse.justPressed)
		{
			// renderedNotes code here.
			
			//
			if (FlxG.mouse.overlaps(curRenderedEvents))
			{
				curRenderedEvents.forEachAlive(function(daEvent:EventNote)
				{
					if (FlxG.mouse.overlaps(daEvent))
					{
						daEvent.kill();
						curRenderedEvents.remove(daEvent, true);
						deleteEvent(daEvent);
						daEvent.destroy();
					}
				});
			}

			//
			if (FlxG.mouse.overlaps(buttonGroup))
			{
				buttonGroup.forEach(function(button:CoolAssButton)
				{
					if (FlxG.mouse.overlaps(button))
					{
						button.onClick(null);
					}
				});
			}
		}

		///*
		if (FlxG.mouse.x > (gridBG.x)
			&& FlxG.mouse.x < (gridBG.x + gridBG.width)
			&& FlxG.mouse.y > 0
			&& FlxG.mouse.y < gridBG.y + (gridSize * _song.notes[currentSection].lengthInSteps))
		{
			var fakeMouseX:Float = FlxG.mouse.x - gridBG.x;

			dummyArrow.x = (Math.floor((fakeMouseX) / gridSize) * gridSize) + gridBG.x;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridSize) * gridSize;

			// moved this in here for the sake of not dying
			if (FlxG.mouse.justPressed)
			{
				if (!FlxG.mouse.overlaps(curRenderedNotes))
				{
					// add note funny
					var noteStrum = getStrumTime(dummyArrow.y);

					var notesSection = Math.floor(noteStrum / (Conductor.stepCrochet * 16));
					var noteData = adjustSide(Math.floor((dummyArrow.x - gridBG.x) / gridSize), _song.notes[notesSection].mustHitSection);
					var noteSus = 0; // ninja you will NOT get away with this

					noteData--;
						
					if (noteData > -1)
						generateChartNote(noteData, noteStrum, noteSus, 0, notesSection);
					else
						generateEvent(noteStrum, null, null, currentSelectedEvent, true);
				}

				else
				{
					curRenderedNotes.forEachAlive(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (FlxG.keys.pressed.CONTROL)
							{
								curSelectedNote = note;
							}
							else
							{
								note.kill();
								curRenderedNotes.remove(note, true);
								deleteNote(note);
								note.destroy();
							}
						}
					});
				}
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
			saveAndClose(FlxG.keys.pressed.SHIFT ? 'FreeplayState' : 'PlayState');

		if (FlxG.keys.justPressed.BACKSPACE) {
			pauseMusic();
			openSubState(new PreferenceSubState(camHUD, 'help'));
		}

		if (FlxG.keys.justPressed.ENTER) {
			pauseMusic();
			openSubState(new PreferenceSubState(camHUD, 'prefs'));
		}

		if (FlxG.keys.anyPressed([W, S]))
		{
			if (curStep <= 0)
				return;
			
			songMusic.pause();
			vocals.pause();

			var speed:Float = 1;

			if (FlxG.keys.pressed.SHIFT)
				speed = 3;

			var daTime:Float = 700 * FlxG.elapsed * speed;

			if (FlxG.keys.pressed.W)
				songMusic.time -= daTime;
			else
				songMusic.time += daTime;

			vocals.time = songMusic.time;
		}
	}

	function saveAndClose(State:String)
	{
		songPosition = songMusic.time;
		PlayState.SONG = _song;

		FlxG.mouse.visible = false;
		ForeverTools.killMusic([songMusic, vocals]);

		Main.changeInfoAlpha(1);

		if (State == 'PlayState')
			Main.switchState(this, new PlayState());
		else
			Main.switchState(this, new FreeplayState());
	}

	function deleteNote(note:Note)
	{
		var data:Null<Int> = note.noteData;

		var noteStrum = getStrumTime(dummyArrow.y);
		var curSection = Math.floor(noteStrum / (Conductor.stepCrochet * 16));

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
	}

	function deleteEvent(event:EventNote)
	{
		var naughtyStrum:Float = event.strumTime;

		for (i in _song.events)
		{
			if (i[0] == naughtyStrum)
			{
				_song.events.remove(i);
				event.kill();
				curRenderedEvents.remove(event, true);
				event.destroy();
				break;
			}
		}
	}

	override public function stepHit()
	{
		// call all rendered notes lol
		curRenderedNotes.forEach(function(epicNote:Note)
		{
			if ((epicNote.y > (strumLineCam.y - (FlxG.height / 2) - epicNote.height))
				|| (epicNote.y < (strumLineCam.y + (FlxG.height / 2))))
			{
				epicNote.alive = true;
				epicNote.visible = true;

				var pain = (Math.floor(Conductor.songPosition / Conductor.stepCrochet));

				// do epic note calls for strum stuffs
				if (pain == Math.floor(epicNote.strumTime / Conductor.stepCrochet))
				{
					var data:Int = epicNote.noteData % 4;
					if (data > -1 && epicNote.mustPress != _song.notes[currentSection].mustHitSection)
						data += 4;

					arrowGroup.members[data].playAnim('confirm', true);
					arrowGroup.members[data].resetAnim = (epicNote.sustainLength / 1000) + 0.2;

					if (!hitSoundsPlayed.contains(epicNote))
					{
						hitSoundsPlayed.push(epicNote);
						FlxG.sound.play(Paths.sound('hitsounds/${PlayState.changeableSound}/hit'));
					}
				}
			}
			else
			{
				epicNote.alive = false;
				epicNote.visible = false;
			}
		});

		super.stepHit();
	}

	function changeSection(?sec:Int = 0, ?stop:Bool = false):Void
	{
		currentSection = sec;

		if (stop)
		{
			vocals.stop();
			songMusic.stop();
		}

		Conductor.songPosition = songMusic.time;

		updateGrid(false);
	}

	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...currentSection + add)
		{
			if (_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += 4 * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function updateGrid(creating:Bool):Void
	{
		curRenderedNotes.clear();
		curRenderedSustains.clear();
		curRenderedEvents.clear();

		var sectionInfo:Array<Dynamic> = _song.notes[currentSection].sectionNotes;
		var eventInfo:Array<Dynamic> = _song.events;

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daNoteType:NoteType = i[3];

			//trace('Current note type is $daNoteType.');

			var keys = 4;

			// 2 = 6k
			if (_song.mania == 2)
				keys = 6;

			generateChartNote(daNoteInfo, daStrumTime, daSus, 0, currentSection, false);
		}

		for (i in eventInfo)
		{
			var strum:Float = i[0];
			var val1:String = i[1];
			var val2:String = i[2];
			var id:String = i[3];

			generateEvent(strum, val1, val2, id, creating);
		}
	}

	function recreateGrid():Void
	{
		gridGroup.clear();

		gridBG = FlxGridOverlay.create(gridSize, gridSize, gridSize * 9, gridSize * 32);
		gridBG.graphic.bitmap.colorTransform(gridBG.graphic.bitmap.rect, new ColorTransform(1, 1, 1, (32 / 255)));
		gridBG.screenCenter(X);
		gridGroup.add(gridBG);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridSize).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridGroup.add(gridBlackLine);

		updateGrid(false);
	}


	public var sectionLineGraphic:FlxGraphic;
	public var sectionCameraGraphic:FlxGraphic;
	public var sectionStepGraphic:FlxGraphic;

	function regenerateSection(section:Int, placement:Float)
	{
		// this will be used to regenerate a box that shows what section the camera is focused on

		// oh and section information lol
		var sectionLine:FlxSprite = new FlxSprite(FlxG.width / 2 - (gridSize * (keysTotal / 2)) - (extraSize / 2), placement);
		sectionLine.frames = sectionLineGraphic.imageFrame;
		sectionLine.alpha = (88 / 255);

		// section camera
		var sectionExtend:Float = 0;
		if (_song.notes[section].mustHitSection)
			sectionExtend = (gridSize * (keysTotal / 2));

		var sectionCamera:FlxSprite = new FlxSprite(FlxG.width / 2 - (gridSize * (keysTotal / 2)) + (sectionExtend), placement);
		sectionCamera.frames = sectionCameraGraphic.imageFrame;
		sectionCamera.alpha = (88 / 255);
		curRenderedSections.add(sectionCamera);

		// set up section numbers
		for (i in 0...2)
		{
			var sectionNumber:FlxText = new FlxText(0, sectionLine.y - 12, 0, Std.string(section), 20);
			// set the x of the section number
			sectionNumber.x = sectionLine.x - sectionNumber.width - 5;
			if (i == 1)
				sectionNumber.x = sectionLine.x + sectionLine.width + 5;

			sectionNumber.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE);
			sectionNumber.antialiasing = false;
			sectionNumber.alpha = sectionLine.alpha;
			curRenderedSections.add(sectionNumber);
		}

		for (i in 1...Std.int(_song.notes[section].lengthInSteps / 4))
		{
			// create a smaller section stepper
			var sectionStep:FlxSprite = new FlxSprite(FlxG.width / 2 - (gridSize * (keysTotal / 2)) - (extraSize / 2), placement + (i * (gridSize * 4)));
			sectionStep.frames = sectionStepGraphic.imageFrame;
			sectionStep.alpha = sectionLine.alpha;
			curRenderedSections.add(sectionStep);
		}

		curRenderedSections.add(sectionLine);
	}

	var sectionsMax = 0;

	function generateNotes()
	{
		// GENERATING THE GRID NOTES!
		curRenderedNotes.clear();
		curRenderedSustains.clear();

		// sectionsMax = 1;
		generateSection();
		for (section in 0..._song.notes.length)
		{
			sectionsMax = section;
			regenerateSection(section, 16 * gridSize * section);

			for (i in _song.notes[section].sectionNotes)
			{
				// note stuffs
				var daNoteAlt:Float = 0;
				if (i.length > 2)
					daNoteAlt = i[3];

				generateChartNote(i[1], i[0], i[2], daNoteAlt, section, false);
			}
		}
		// lolll
		// sectionsMax--;
	}

	var extraSize = 6;

	function generateSection() 
	{ 
		// pregenerate assets so it doesnt destroy your ram later
		sectionLineGraphic = FlxG.bitmap.create(gridSize * keysTotal + extraSize, 2, FlxColor.WHITE);
		sectionCameraGraphic = FlxG.bitmap.create(Std.int(gridSize * (keysTotal / 2)), 16 * gridSize, FlxColor.fromRGB(43, 116, 219));
		sectionStepGraphic = FlxG.bitmap.create(gridSize * keysTotal + extraSize, 1, FlxColor.WHITE);
	}

	function loadSong(daSong:String):Void
	{
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		songMusic = new FlxSound().loadEmbedded(Paths.inst(daSong), false, true);

		if (_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong), false, true);
		else
			vocals = new FlxSound();
		
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		vocals.play();

		if (curSong == _song)
			songMusic.time = songPosition;
		
		curSong = _song;
		songPosition = 0;

		pauseMusic();

		songMusic.onComplete = function()
		{
			ForeverTools.killMusic([songMusic, vocals]);
			loadSong(daSong);
		};
	}

	function generateChartNote(daNoteInfo, daStrumTime, daSus, daNoteAlt:Float, noteSection, ?shouldPush:Bool = true)
	{
		//trace(daNoteInfo);

		var note:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteInfo % 4, 0, false, null);
		note.rawNoteData = daNoteInfo;
		note.sustainLength = daSus;
		note.setGraphicSize(gridSize, gridSize);
		note.updateHitbox();
		note.screenCenter(X);
		note.x = Math.ffloor(daNoteInfo * gridSize) + gridSize;
		note.x += 418;
		note.y = Math.ffloor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[currentSection].lengthInSteps)));	
		
		if (shouldPush)
		{
			_song.notes[noteSection].sectionNotes.push([daStrumTime, (daNoteInfo + 4) % 8, daSus, NORMAL]);
			curSelectedNote = note;
		}

		curRenderedNotes.add(note);
		//generateSustain(daStrumTime, daNoteInfo, daSus, daNoteAlt, note);
	}

	function generateEvent(strumTime:Float, val1:String, val2:String, id:String, ?shouldPush:Bool = false):Void
	{
		var event:Array<Dynamic> = [strumTime, val1, val2, id];
		
		var eventNote:EventNote = new EventNote(strumTime, val1, val2, id);
		eventNote.setGraphicSize(gridSize, gridSize);
		eventNote.updateHitbox();
		//eventNote.screenCenter(X);
		eventNote.x += 370;
		eventNote.y = Math.floor(getYfromStrum((event[0] - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[currentSection].lengthInSteps)));

		if (shouldPush)
		{
			_song.events.push(event);
		} 

		//trace('EVENT GENERATED');

		curRenderedEvents.add(eventNote);
	}

	function generateSustain(daStrumTime:Float = 0, daNoteInfo:Int = 0, daSus:Float = 0, daNoteAlt:Float = 0, note:Note)
	{
		/*
			if (daSus > 0)
			{
				//prevNote = note;
				var constSize = Std.int(gridSize / 3);

				var sustainVis:Note = new Note(daStrumTime + (Conductor.stepCrochet * daSus) + Conductor.stepCrochet, daNoteInfo % 4, daNoteAlt, prevNote, true);
				sustainVis.setGraphicSize(constSize,
					Math.floor(FlxMath.remapToRange((daSus / 2) - constSize, 0, Conductor.stepCrochet * verticalSize, 0, gridSize * verticalSize)));
				sustainVis.updateHitbox();
				sustainVis.x = note.x + constSize;
				sustainVis.y = note.y + (gridSize / 2);

				var sustainEnd:Note = new Note(daStrumTime + (Conductor.stepCrochet * daSus) + Conductor.stepCrochet, daNoteInfo % 4, daNoteAlt, sustainVis, true);
				sustainEnd.setGraphicSize(constSize, constSize);
				sustainEnd.updateHitbox();
				sustainEnd.x = sustainVis.x;
				sustainEnd.y = note.y + (sustainVis.height) + (gridSize / 2);

				// loll for later
				sustainVis.rawNoteData = daNoteInfo;
				sustainEnd.rawNoteData = daNoteInfo;

				curRenderedSustains.add(sustainVis);
				curRenderedSustains.add(sustainEnd);
				//

				// set the note at the current note map
				curNoteMap.set(note, [sustainVis, sustainEnd]);
			}
		*/
	}

	///*
	var coolGrid:FlxBackdrop;
	var coolGradient:FlxSprite;

	function generateBackground()
	{
		coolGrid = new FlxBackdrop(null, 1, 1, true, true, 1, 1);
		coolGrid.loadGraphic(Paths.image('UI/forever/base/chart editor/grid'));
		coolGrid.screenCenter();
		coolGrid.alpha = (32 / 255);
		add(coolGrid);

		// gradient
		coolGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(188, 158, 255, 200), FlxColor.fromRGB(80, 12, 108, 255), 16));
		coolGradient.alpha = (32 / 255);
		coolGradient.screenCenter();
		add(coolGradient);
	}

	function generateButtons():Void
	{
		// x, y, text on button, text size, child (optional), size ("" (medium), "big", or "small"),
		// function that will be called when pressed (optional)
		
		buttonArray = [
			[FlxG.width - 180, 20, "RELOAD SONG", 20, null, "", null],
			[FlxG.width - 240, 70, "SWAP SECTION NOTES", 20, null, "", null],
			[FlxG.width - 240, 120, "COPY SECTION NOTES", 20, null, "", null],
			[FlxG.width - 240, 170, "PASTE SECTION NOTES", 20, null, "", null]
		];

		buttonGroup.clear();
		buttonTextGroup.clear();

		var void:Void -> Void = null;

		for (i in buttonArray)
		{
			if (i != null)
			{
				//trace(i);

				switch (i[2].toLowerCase())
				{
					case 'reload song':
						void = function()
						{
							loadSong(PlayState.SONG.song);
							FlxG.resetState();
						};

					case 'swap section notes':
						void = function()
						{
							for (i in 0..._song.notes[currentSection].sectionNotes.length)
							{
								var note = _song.notes[currentSection].sectionNotes[i];

								// must press
								var keys = 4;

								// in total
								var tolKeys = 8;

								note[1] = (note[1] + keys) % tolKeys;
								_song.notes[currentSection].sectionNotes[i] = note;
								updateGrid(false);
							}
						};

					default:
						void = i[6];
				}

				var button:CoolAssButton = new CoolAssButton(i[0], i[1], i[5], null);
				button.child = i[4];
				button.clickThing = void;
				buttonGroup.add(button);

				var text:AbsoluteText = new AbsoluteText(i[2], i[3], button, 10, 10);
				text.scrollFactor.set();
				buttonTextGroup.add(text);
			}
		}
	}

	var editorTxt:FlxText;
	var songTxt:FlxText;
	var helpTxt:FlxText;
	var prefTxt:FlxText;
	var bpmTxt:FlxText;

	function generateText()
	{
		// text stuffs
		editorTxt = new FlxText(10, 20, 0, "", 16);
		editorTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		editorTxt.scrollFactor.set();
		add(editorTxt);

		songTxt = new FlxText(10, 45, 0, "", 16);
		songTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		songTxt.scrollFactor.set();
		add(songTxt);

		editorTxt.text = 'CHART EDITOR\n';
		songTxt.text = _song.song.toUpperCase()
			+ ' <${CoolUtil.difficultyFromNumber(PlayState.storyDifficulty)}> '
			+ 'BY '
			+ _song.author.toUpperCase()
			+ '\n';

		bpmTxt = new FlxText(5, FlxG.height - 30, 0, "", 16);
		bpmTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		helpTxt = new FlxText(0, 0, 0, "", 16);
		helpTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		helpTxt.scrollFactor.set();
		add(helpTxt);

		prefTxt = new FlxText(0, 0, 0, "", 16);
		prefTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		prefTxt.scrollFactor.set();
		add(prefTxt);

		helpTxt.text = 'PRESS BACKSPACE FOR HELP';
		prefTxt.text = 'PRESS ENTER FOR PREFERENCES';

		helpTxt.setPosition(FlxG.width - (helpTxt.width + 5), FlxG.height - 55);
		prefTxt.setPosition(FlxG.width - (prefTxt.width + 5), FlxG.height - 30);
	}

	function updateText()
	{
		bpmTxt.text = bpmTxt.text = Std.string('BEAT: '
			+ FlxMath.roundDecimal(decBeat, 2) // + '  STEP: ' + curStep
			+ '  MEASURE: '
			+ currentSection
			+ '  TIME: '
			+ FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + '  BPM: ' + _song.bpm;
	}

	function adjustSide(noteData:Int, sectionTemp:Bool):Int
	{
		return (sectionTemp ? ((noteData + 4) % 8) : noteData);
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

	function pauseMusic()
	{
		songMusic.time = Math.max(songMusic.time, 0);
		songMusic.time = Math.min(songMusic.time, songMusic.length);

		resyncVocals();
		songMusic.pause();
		vocals.pause();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		songMusic.play();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
}