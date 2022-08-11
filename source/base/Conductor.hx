package base;

import base.Conductor.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/*
	Stuff like this is why this is a mod engine and not a rewrite.
	I'm not going to pretend to know what any of this does and I don't really have the motivation to
	go through it and rewrite it if I think it works just fine, but there are other aspects that I wanted to
	change about the game entirely which I wanted to rewrite so that's why I made this.

	I'll take a look later if it's important for anything. Otherwise, I don't think this code needs to be edited
	for things like other mods and such, maybe for base engine functions. who knows? we'll see.

	Told myself I wasn't gonna bother with this cus I was lazy but now I actually have to and I hate myself for not doing it earlier!
 */
typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

/**
* Song Information, such as name, notes, events, bpm, etc;
**/
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Array<Dynamic>>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var noteSkin:String;
	var splashSkin:String;
	var author:String;
	var assetModifier:String;
	var validScore:Bool;
	var ?offset:Int;
	var mania:Int;
}

/**
* Song Meta Information, such as author, asset modifier and offset;
**/
typedef SwagMeta =
{
	var author:String;
	var assetModifier:String;
	var ?offset:Int;
}

/**
* Song Section Information;
**/
typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Conductor
{
	public static var bpm:Float = 100;

	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	/*
		public static var safeFrames:Int = 10;
		public static var safeZoneOffset:Float = (safeFrames / 60) * 1000;
	 */
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		// trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float, measure:Float = 4 / 4)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = (crochet / 4) * measure;
	}
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadSong(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = '';
		var rawMeta = '';

		try
		{
			rawJson = File.getContent(Paths.songJson(folder.toLowerCase(), jsonInput.toLowerCase())).trim();
		}
		catch (e)
		{
			rawJson = null;
		}

		if (rawJson != null)
		{
			while (!rawJson.endsWith("}"))
				rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		try
		{
			rawMeta = File.getContent(Paths.songJson(folder.toLowerCase(), 'meta')).trim();
		}
		catch (e)
		{
			rawMeta = null;
		}

		if (rawMeta != null)
		{
			while (!rawMeta.endsWith("}"))
				rawMeta = rawMeta.substr(0, rawMeta.length - 1);
		}

		if (rawMeta == null)
		{
			rawMeta = '{
				"author": "???",
				"assetModifier": "base",
				"offset": 0
			}';
		}

		return parseSong(rawJson, rawMeta);
	}

	public static function parseSong(rawJson:String, rawMeta:String = 'meta'):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;

		var swagMeta:SwagMeta = cast Json.parse(rawMeta);

		// injecting info from the meta file if it's valid data, else get from the song data
		// please spare me I know it looks weird.
		if (swagMeta.assetModifier != null)
			swagShit.assetModifier = swagMeta.assetModifier;
		else if (swagMeta.assetModifier == null)
			swagShit.assetModifier = swagShit.assetModifier;
		else
			swagShit.assetModifier == 'base';

		if (swagMeta.author != null)
			swagShit.author = swagMeta.author;
		else if (swagMeta.author == null)
			swagShit.author = swagShit.author;
		else
			swagShit.author = '???';

		if (swagMeta.offset != null)
			swagShit.offset = swagMeta.offset;
		else if (swagMeta.offset == null)
			swagShit.offset = swagShit.offset;
		else
			swagShit.offset = 0;

		return swagShit;
	}
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}
