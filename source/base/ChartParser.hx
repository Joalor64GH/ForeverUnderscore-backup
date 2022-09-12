package base;

import Paths.ChartType;
import base.SongLoader;
import flixel.util.FlxSort;
import funkin.EventNote;
import funkin.Note;
import states.PlayState;

using StringTools;

/**
 * This is the ChartParser class. it loads in charts, but also exports charts, the chart parameters are based on the type of chart, 
 * say the base game type loads the base game's charts, the forever chart type loads a custom forever structure chart with custom features,
 * and so on. This class will handle both saving and loading of charts with useful features and scripts that will make things much easier
 * to handle and load, as well as much more modular!
**/

typedef SongFormat = // new song format which i'm setting up later
{
	var song:String;
	var bpm:Float;
	var events:Array<SongEvent>;
	var notes:Array<SongNote>;
	var speed:Float;
}

class ChartParser
{
	public static var songType:ChartType = UNDERSCORE;

	// hopefully this makes it easier for people to load and save chart features and such, y'know the deal lol
	public static function loadChart(songData:LegacySong, songType:ChartType = FNF_LEGACY):Array<Note>
	{
		var unspawnNotes:Array<Note> = [];
		var noteData:Array<LegacySection>;

		noteData = songData.notes;
		switch (songType)
		{
			case FNF:
			// placeholder until 0.3!
			case FNF_LEGACY:
				// load fnf style charts (PRE 0.3)
				var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

				for (section in noteData)
				{
					for (songNotes in section.sectionNotes)
					{
						var daStrumTime:Float = #if !neko songNotes[0] - Init.trueSettings['Offset'] /*/ Conductor.songPlaybackRate*/ /* - | late, + | early*/ #else songNotes[0] /*/ Conductor.songPlaybackRate*/ #end;
						var daNoteData:Int = Std.int(songNotes[1] % 4);
						// define the note's animation (in accordance to the original game)!
						var daNoteAlt:Float = 0;

						// very stupid but I'm lazy
						if (songNotes.length > 2)
							daNoteAlt = songNotes[3];

						/**
						 * rest of this code will be mostly unmodified, I don't want to interfere with how FNF chart loading works
						 * I'll keep all of the extra features in forever charts, which you'll be able to convert and export to very easily using
						 * the in engine editor 
						 * 
						 * I'll be doing my best to comment the work below but keep in mind I didn't originally write it
						**/

						// check the base section
						var gottaHitNote:Bool = section.mustHitSection;

						// if the note is on the other side, flip the base section of the note
						if (songNotes[1] > 3)
							gottaHitNote = !section.mustHitSection;

						// define the note that comes before (previous note)
						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else // if it exists, that is
							oldNote = null;

						// create the new note
						var swagNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteData, daNoteAlt);
						// set note speed
						swagNote.noteSpeed = songData.speed;

						// set the note's length (sustain note)
						swagNote.sustainLength = songNotes[2] /*/ Conductor.songPlaybackRate*/;
						swagNote.scrollFactor.set(0, 0);
						var susLength:Float = swagNote.sustainLength; // sus amogus

						// adjust sustain length
						susLength = susLength / Conductor.stepCrochet;
						// push the note to the array we'll push later to the playstate
						unspawnNotes.push(swagNote);
						// STOP POSTING ABOUT AMONG US
						// basically said push the sustain notes to the array respectively
						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
								daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteAlt, true, oldNote);
							sustainNote.scrollFactor.set();

							unspawnNotes.push(sustainNote);
							sustainNote.mustPress = gottaHitNote;
						}

						// oh and set the note's must hit section
						swagNote.mustPress = gottaHitNote;
					}
					daBeats += 1;
				}

			case FOREVER:
			// placeholder

			case UNDERSCORE:
				/**
				 * a copy of FNF_LEGACY, except we have notetypes and events, that's all
				 * I don't exactly know how chart parsing works, so I'm leaving it like this for the time being
				 * 
				 * - BeastlyGhost
				**/

				var daBeats:Int = 0;

				for (section in noteData)
				{
					for (songNotes in section.sectionNotes)
					{
						var daStrumTime:Float = songNotes[0]#if !neko - Init.trueSettings['Offset'] #end; // - | late, + | early
						var daNoteData:Int = Std.int(songNotes[1] % 4);
						var daNoteAlt:Float = 0;
						var daNoteType:Int = 0; // define the note's type

						if (songNotes.length > 2)
						{
							daNoteType = songNotes[3];
						}
						var gottaHitNote:Bool = section.mustHitSection;
						if (songNotes[1] > 3)
							gottaHitNote = !section.mustHitSection;

						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else
							oldNote = null;

						var swagNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteData, daNoteAlt, daNoteType);
						swagNote.noteSpeed = songData.speed;

						swagNote.sustainLength = songNotes[2];
						swagNote.scrollFactor.set(0, 0);

						var susLength:Float = swagNote.sustainLength;
						susLength = susLength / Conductor.stepCrochet;
						unspawnNotes.push(swagNote);

						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
								daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteAlt, true, oldNote, daNoteType);
							sustainNote.scrollFactor.set();

							unspawnNotes.push(sustainNote);
							sustainNote.mustPress = gottaHitNote;
						}

						swagNote.mustPress = gottaHitNote;
					}

					daBeats += 1;
				}
			case PSYCH:
				// placeholder
		}

		// sort notes before returning them;
		unspawnNotes.sort(function(Obj1:Note, Obj2:Note):Int
		{
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
		});

		return unspawnNotes;
	}

	public static function loadEvents(eventData:LegacySong, songType:ChartType = FNF_LEGACY):Array<EventNote>
	{
		var unspawnEvents:Array<EventNote> = [];

		/*
		if (eventData.events != null && eventData.events.length > 0)
		{
			for (i in 0...eventData.events.length)
			{
				if (eventData.events[i] != null && eventData.events[i].length > 0)
				{
					for (event in eventData.events[i])
					{
						var eventNote:EventNote = new EventNote(event[1], event[0], event[2], event[3]);
						eventNote.visible = false;
						unspawnEvents.push(eventNote);
					}
				}
			}
		}
		*/

		unspawnEvents.sort(function(event1:EventNote, event2:EventNote):Int
		{
			return FlxSort.byValues(FlxSort.ASCENDING, event1.strumTime, event2.strumTime);
		});

		return unspawnEvents;
	}
}
