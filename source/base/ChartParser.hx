package base;

import flixel.util.FlxSort;
import funkin.Note;
import states.PlayState;
import base.SongLoader;

using StringTools;

/**
 * This is the ChartParser class. it loads in charts, but also exports charts, the chart parameters are based on the type of chart, 
 * say the base game type loads the base game's charts, the forever chart type loads a custom forever structure chart with custom features,
 * and so on. This class will handle both saving and loading of charts with useful features and scripts that will make things much easier
 * to handle and load, as well as much more modular!
**/
class ChartParser
{
	public static function loadChart(songData:LegacySong):Array<Note>
	{
		var unspawnNotes:Array<Note> = [];
		var noteData:Array<LegacySection>;

		noteData = songData.notes;
		var daBeats:Int = 0;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] - songData.offset #if !neko - Init.trueSettings['Offset'] #end; // - | late, + | early
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteAlt:Float = 0;
				var daNoteType:Int = 0; // define the note's type

				if (songNotes.length > 2)
					daNoteType = songNotes[3];

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
				swagNote.noteType = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;

				if (swagNote.noteData > -1) // don't push notes if they are an event??
					unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					var sustainNote:Note = ForeverAssets.generateArrow(PlayState.assetModifier,
						daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteAlt, true, oldNote, daNoteType);
					sustainNote.scrollFactor.set();

					if (sustainNote.noteData > -1)
						unspawnNotes.push(sustainNote);
					sustainNote.mustPress = gottaHitNote;
				}

				swagNote.mustPress = gottaHitNote;
			}

			daBeats += 1;
		}

		// sort notes before returning them;
		unspawnNotes.sort(function(Obj1:Note, Obj2:Note):Int
		{
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
		});

		return unspawnNotes;
	}

	public static function loadChartEvents(songData:LegacySong):Array<Note>
	{
		// placeholder;
		var unspawnedEvents:Array<Note> = [];
		return unspawnedEvents;
	}
}
