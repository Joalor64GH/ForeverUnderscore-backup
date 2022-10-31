package funkin;

import base.*;
import dependency.FNFSprite;
import flixel.FlxG;
import states.PlayState;
import funkin.Strumline.Receptor;

using StringTools;

class Note extends FNFSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var noteAlt:Float = 0;
	public var noteType:Int = 0;

	public var noteString:String = '';

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustain:Bool = false;

	// offsets
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var lowPriority:Bool = false;
	public var hitboxLength:Float = 1;

	public var useCustomSpeed:Bool = Init.getSetting('Use Custom Note Speed');
	public var noteSpeed(default, set):Float;

	public function set_noteSpeed(value:Float):Float
	{
		if (noteSpeed != value)
		{
			noteSpeed = value;
			updateSustainScale();
		}
		return noteSpeed;
	}

	public var noteQuant:Int = -1;
	public var noteVisualOffset:Float = 0;
	public var noteDirection:Float = 0;

	public var parentNote:Note;
	public var childrenNotes:Array<Note> = [];

	// it has come to this.
	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	public var healthGain:Float = 0.023;
	public var healthLoss:Float = 0.0475;
	public var holdHeight:Float = 0.72;

	public var hitSounds:Bool = true;
	public var canHurt:Bool = false;
	public var cpuIgnore:Bool = false;
	public var gfNote:Bool = false;
	public var updateAccuracy:Bool = true;

	public var hitsoundSuffix = '';

	static var pixelNoteID:Array<Int> = [4, 5, 6, 7];
	public static var noteTypeNames:Array<String> = ['Normal Note', 'GF Note', 'Mine Note'];

	function resetNote(isGf:Bool = false)
	{
		hitSounds = true;
		updateAccuracy = true;
		cpuIgnore = false;
		canHurt = false;
		gfNote = isGf;
		lowPriority = false;
		noteString = '';
	}

	public function new(strumTime:Float, noteData:Int, noteAlt:Float, ?prevNote:Note, ?isSustain:Bool = false,
		?noteType:Int = 0, ?noteString:String)
	{
		super(x, y);

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.noteType = noteType;
		this.noteString = noteString;
		this.isSustain = isSustain;

		if (noteType == null || noteType <= 0)
			noteType = 0;

		if (noteString == null)
			noteString = '';

		switch (noteType)
		{
			case 1: // gf notes
				resetNote(true);
			case 2: // mines
				healthLoss = 0.065;
				updateAccuracy = true;
				hitSounds = false;
				cpuIgnore = true;
				canHurt = true;
				gfNote = false;
				lowPriority = true;
				noteString = 'miss';
			default: // anything else
				resetNote(false);
		}

		// oh okay I know why this exists now
		y -= 2000;

		this.strumTime = strumTime;
		this.noteData = noteData;
		this.noteAlt = noteAlt;

		// determine parent note
		if (isSustain && prevNote != null)
		{
			parentNote = prevNote;
			if (parentNote.noteString != null)
				this.noteString = parentNote.noteString;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);

			hitSounds = false;
		}
		else if (!isSustain)
			parentNote = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - (Timings.msThreshold * hitboxLength)
				&& strumTime < Conductor.songPosition + (Timings.msThreshold * hitboxLength))
				canBeHit = true;
			else
				canBeHit = false;
		}
		else // make sure the note can't be hit if it's the dad's I guess
			canBeHit = false;

		if (tooLate || (parentNote != null && parentNote.tooLate))
			alpha = 0.3;
	}

	public function updateSustainScale()
	{
		if (isSustain)
		{
			if (prevNote != null && prevNote.exists)
			{
				if (prevNote.isSustain)
				{
					// listen I dont know what i was doing but I was onto something (-yoshubs)
					// yoshubs this literally works properly (-gabi)
					prevNote.scale.y = (prevNote.width / prevNote.frameWidth) * ((Conductor.stepCrochet / 100) * (1.07 / holdHeight)) * noteSpeed;
					prevNote.updateHitbox();
					offsetX = prevNote.offsetX;
				}
				else
					offsetX = ((prevNote.width / 2) - (width / 2));
			}
		}
	}

	/**
		Note creation scripts

		these are for all your custom note needs

		at the very bottom of this file you can find the function
		for setting up custom note behavior when hit and such
	**/
	public static function returnDefaultNote(assetModifier:String, strumTime:Float, noteData:Int, noteAlt:Float, ?isSustain:Bool = false, ?prevNote:Note,
			?noteType:Int = 0):Note
	{
		var newNote:Note = new Note(strumTime, noteData, noteAlt, prevNote, isSustain, noteType);
		newNote.holdHeight = 0.72;

		// frames originally go here
		switch (assetModifier)
		{
			case 'pixel':
				if (isSustain)
				{
					switch (noteType)
					{
						case 2:
							newNote.kill();
						default: // pixel holds default
							reloadPrefixes('arrowEnds', 'noteskins/notes', Init.getSetting("Note Skin"), assetModifier, newNote);
					}
				}
				else
				{
					switch (noteType)
					{
						case 2: // pixel mines;
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkin('mines', assetModifier, '', 'noteskins/mines')), true, 17, 17);
							newNote.animation.add(Receptor.colors[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7], 12);

						default: // pixel notes default
							reloadPrefixes('arrows-pixels', 'noteskins/notes', Init.getSetting("Note Skin"), assetModifier, newNote);
					}
				}
				newNote.antialiasing = false;
				newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
				newNote.updateHitbox();

			default: // base game arrows for no reason whatsoever
				switch (noteType)
				{
					case 2: // mines
						newNote.loadGraphic(Paths.image(ForeverTools.returnSkin('mines', assetModifier, '', 'noteskins/mines')), true, 133, 128);
						newNote.animation.add(Receptor.colors[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

						if (isSustain)
							newNote.kill();

						newNote.setGraphicSize(Std.int(newNote.width * 0.8));
						newNote.updateHitbox();
						newNote.antialiasing = !Init.getSetting('Disable Antialiasing');
					default: // anything else
						reloadPrefixes("NOTE_assets", 'noteskins/notes', Init.getSetting("Note Skin"), assetModifier, newNote);
				}
		}
		//
		if (!isSustain)
			newNote.animation.play(Receptor.colors[noteData] + 'Scroll');

		if (isSustain && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = Init.getSetting('Hold Opacity') * 0.01;

			newNote.animation.play(Receptor.colors[noteData] + 'holdend');
			newNote.updateHitbox();

			if (prevNote != null && prevNote.isSustain)
			{
				prevNote.animation.play(Receptor.colors[prevNote.noteData] + 'hold');
				prevNote.updateHitbox();
			}
		}

		return newNote;
	}

	public static function returnQuantNote(assetModifier:String, strumTime:Float, noteData:Int, noteAlt:Float, ?isSustain:Bool = false, ?prevNote:Note = null,
			?noteType:Int = 0):Note
	{
		var newNote:Note = new Note(strumTime, noteData, noteAlt, prevNote, isSustain, noteType);
		newNote.holdHeight = 0.862;

		// actually determine the quant of the note
		determineQuantIndex(strumTime, newNote);

		// note quants
		switch (assetModifier)
		{
			default:
				// inherit last quant if hold note
				if (isSustain && prevNote != null)
					newNote.noteQuant = prevNote.noteQuant;
				// base quant notes
				if (!isSustain)
				{
					switch (noteType)
					{
						case 2: // pixel mines
							if (assetModifier == 'pixel')
							{
								newNote.loadGraphic(Paths.image(ForeverTools.returnSkin('mines', assetModifier, '', 'noteskins/mines')), true, 17, 17);
								newNote.animation.add(Receptor.actions[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7], 12);
							}
							else
							{
								newNote.loadGraphic(Paths.image(ForeverTools.returnSkin('mines', assetModifier, '', 'noteskins/mines')), true, 133, 128);
								newNote.animation.add(Receptor.actions[noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 12);
							}

						default:
							// in case you're unfamiliar with these, they're ternary operators, I just dont wanna check for pixel notes using a separate statement
							var newNoteSize:Int = (assetModifier == 'pixel') ? 17 : 157;
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkin('NOTE_quants', assetModifier, Init.getSetting("Note Skin"),
								'noteskins/notes', 'quant')),
								true, newNoteSize, newNoteSize);

							newNote.animation.add('leftScroll', [0 + (newNote.noteQuant * 4)]);
							// LOL downscroll thats so funny to me
							newNote.animation.add('downScroll', [1 + (newNote.noteQuant * 4)]);
							newNote.animation.add('upScroll', [2 + (newNote.noteQuant * 4)]);
							newNote.animation.add('rightScroll', [3 + (newNote.noteQuant * 4)]);
					}
				}
				else
				{
					switch (noteType)
					{
						case 2:
							newNote.kill();
						default:
							// quant holds
							newNote.loadGraphic(Paths.image(ForeverTools.returnSkin('HOLD_quants', assetModifier, Init.getSetting("Note Skin"),
								'noteskins/notes', 'quant')),
								true, (assetModifier == 'pixel') ? 17 : 109, (assetModifier == 'pixel') ? 6 : 52);
							newNote.animation.add('hold', [0 + (newNote.noteQuant * 4)]);
							newNote.animation.add('holdend', [1 + (newNote.noteQuant * 4)]);
							newNote.animation.add('roll', [2 + (newNote.noteQuant * 4)]);
							newNote.animation.add('rollend', [3 + (newNote.noteQuant * 4)]);
					}
				}

				var sizeThing = 0.7;
				if (noteType == 5)
					sizeThing = 0.8;

				if (assetModifier == 'pixel')
				{
					newNote.antialiasing = false;
					newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
					newNote.updateHitbox();
				}
				else
				{
					newNote.setGraphicSize(Std.int(newNote.width * sizeThing));
					newNote.updateHitbox();
					newNote.antialiasing = !Init.getSetting('Disable Antialiasing');
				}
		}

		if (!isSustain)
			newNote.animation.play(Receptor.actions[noteData] + 'Scroll');

		if (isSustain && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = Init.getSetting('Hold Opacity') * 0.01;

			newNote.animation.play('holdend');
			newNote.updateHitbox();

			if (prevNote.isSustain)
			{
				prevNote.animation.play('hold');

				// prevNote.scale.y *= Conductor.stepCrochet / 100 * (43 / 52) * 1.5 * prevNote.noteSpeed;
				// prevNote.updateHitbox();
			}
		}

		return newNote;
	}

	static function reloadPrefixes(texture:String, texturePath:String, changeable:String = '', assetModifier:String, newNote:Note)
	{
		if (assetModifier != 'pixel')
		{
			newNote.frames = Paths.getSparrowAtlas(ForeverTools.returnSkin(texture, assetModifier, changeable, texturePath));

			newNote.animation.addByPrefix(Receptor.colors[newNote.noteData] + 'Scroll', Receptor.colors[newNote.noteData] + '0');
			newNote.animation.addByPrefix(Receptor.colors[newNote.noteData] + 'holdend', Receptor.colors[newNote.noteData] + ' hold end');
			newNote.animation.addByPrefix(Receptor.colors[newNote.noteData] + 'hold', Receptor.colors[newNote.noteData] + ' hold piece');

			newNote.animation.addByPrefix('purpleholdend', 'pruple end hold'); // PA god dammit.

			newNote.antialiasing = !Init.getSetting('Disable Antialiasing');
			newNote.setGraphicSize(Std.int(newNote.width * 0.7));
			newNote.updateHitbox();
		}
		else
		{
			if (newNote.isSustain)
			{
				newNote.loadGraphic(Paths.image(ForeverTools.returnSkin(texture, assetModifier, changeable, texturePath)), true, 7, 6);
				newNote.animation.add(Receptor.colors[newNote.noteData] + 'holdend', [pixelNoteID[newNote.noteData]]);
				newNote.animation.add(Receptor.colors[newNote.noteData] + 'hold', [pixelNoteID[newNote.noteData] - 4]);
			}
			else
			{
				newNote.loadGraphic(Paths.image(ForeverTools.returnSkin(texture, assetModifier, changeable, texturePath)), true, 17, 17);
				newNote.animation.add(Receptor.colors[newNote.noteData] + 'Scroll', [pixelNoteID[newNote.noteData]], 12);
			}
		}
	}

	// will be later replacing this function in favor of an actual scripted notetype system;

	/**
	 * Custom Note Functions (for when you hit a note), this should execute in PlayState;
	**/
	public function goodNoteHit(newNote:Note, ?ratingTiming:String)
	{
		var hitsound = Init.getSetting('Hitsound Type');
		switch (newNote.noteType)
		{
			case 2:
				PlayState.contents.decreaseCombo(true);
				PlayState.health -= healthLoss;
			default:
				if (newNote.hitSounds)
				{
					if (Init.getSetting('Hitsound Volume') > 0 && newNote.canBeHit)
						FlxG.sound.play(Paths.sound('hitsounds/$hitsound/hit$hitsoundSuffix'), Init.getSetting('Hitsound Volume'));
				}
		}
	}

	/**
	 * [Specify what to do when a note is missed];
	 */
	public function noteMissActions(?coolNote:Note)
	{
		switch (coolNote.noteType)
		{
			default:
				// do nothing;
		}
	}

	public static function determineQuantIndex(strumTime:Float, newNote:Note)
	{
		/*
			I have to credit like 3 different people for these LOL they were a hassle
			but its gede pixl and scarlett, thank you SO MUCH for baring with me
		 */
		final quantArray:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

		var songOffset:Float = 0;
		var curBPM:Float = Conductor.bpm;
		var newTime = strumTime;

		final beatTimeSeconds:Float = (60 / curBPM); // beat in seconds
		final beatTime:Float = beatTimeSeconds * 1000; // beat in milliseconds
		final measureTime:Float = beatTime * 4; // assumed 4 beats per measure?

		final smallestDeviation:Float = measureTime / quantArray[quantArray.length - 1];

		songOffset = (PlayState.SONG != null ? PlayState.SONG.offset : 0);

		if (newNote.noteQuant == -1)
		{
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (strumTime > Conductor.bpmChangeMap[i].songTime)
				{
					curBPM = Conductor.bpmChangeMap[i].bpm;
					newTime = strumTime - Conductor.bpmChangeMap[i].songTime;
				}
			}

			for (quant in 0...quantArray.length)
			{
				// please generate this ahead of time and put into array :)
				// I dont think I will im scared of those
				final quantTime = (measureTime / quantArray[quant]);
				if ((newTime + songOffset #if !neko + Init.trueSettings['Offset'] #end + smallestDeviation) % quantTime < smallestDeviation * 2)
				{
					// here it is, the quant, finally!
					newNote.noteQuant = quant;
					break;
				}
			}
		}

		return quantArray.length - 1;
	}
}
