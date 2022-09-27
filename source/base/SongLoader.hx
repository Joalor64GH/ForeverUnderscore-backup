package base;

import haxe.Json;
import sys.io.File;

using StringTools;

/**
 * tbh, i think the legacy fnf format sucks ass
 * i'm gonna try to write a new one later with compatibility
 * for base game charts and such
 * -gabi (BeastlyGhost)
 */
typedef LegacySong =
{
	var song:String;
	var notes:Array<LegacySection>;
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
	var ?color:Array<Int>;
}

typedef LegacySection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float; // for Psych Engine v0.6+ chart compatibility;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef SongInfo =
{
	var author:String;
	var assetModifier:String;
	var ?offset:Int;
	var ?color:Array<Int>;
	var ?difficulties:Array<String>;
}

class Song
{
	public var song:String;
	public var notes:Array<LegacySection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadSong(jsonInput:String, ?folder:String):LegacySong
	{
		var rawJson = '';
		var rawMeta = '';
		var rawEvent:String = null;

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

		try
		{
			rawEvent = File.getContent(Paths.songJson(folder.toLowerCase(), 'events').trim()).trim();
		}
		catch (e)
		{
			rawEvent = null;
		}
		if (rawMeta == null)
		{
			rawMeta = '{
				"author": "???",
				"assetModifier": "base",
				"offset": 0,
				"color": [255, 255, 255]
			}';
		}

		return parseSong(rawJson, rawMeta, rawEvent);
	}

	public static function parseSong(rawJson:String, rawMeta:String, rawEvent:String):LegacySong
	{
		var oldSong:LegacySong = cast Json.parse(rawJson).song;
		oldSong.validScore = true;

		if (rawMeta != null)
		{
			var songMeta:SongInfo = cast Json.parse(rawMeta);

			// injecting info from the meta file if it's valid data, else get from the song data
			// please spare me I know it looks weird.
			if (songMeta.assetModifier != null)
				oldSong.assetModifier = songMeta.assetModifier;
			else if (songMeta.assetModifier == null)
				oldSong.assetModifier = oldSong.assetModifier;
			else
				oldSong.assetModifier == 'base';

			if (songMeta.author != null)
				oldSong.author = songMeta.author;
			else if (songMeta.author == null)
				oldSong.author = oldSong.author;
			else
				oldSong.author = '???';

			if (songMeta.offset != null)
				oldSong.offset = songMeta.offset;
			else if (songMeta.offset == null)
				oldSong.offset = oldSong.offset;
			else
				oldSong.offset = 0;

			if (songMeta.color != null)
				oldSong.color = songMeta.color;
			else if (songMeta.color == null)
				oldSong.color = oldSong.color;
			else
				oldSong.color = [255, 255, 255];

			// temporary custom difficulty things;
			if (songMeta.difficulties != null)
			{
				for (i in songMeta.difficulties)
				{
					if (i != null && i.length > 1 && !CoolUtil.difficulties.contains(i))
					{
						// clear previous difficulties;
						// CoolUtil.difficulties = [];
						// add new ones;
						// CoolUtil.difficulties.push(i);
					}
				}
			}
		}

		if (rawEvent != null)
			oldSong.events = Json.parse(rawEvent).events;
		else
			oldSong.events = [];

		return oldSong;
	}
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var sectionBeats:Float = 4;
	public var typeOfSection:Int = 0;
	public var gfSection:Bool = false;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(sectionBeats:Float = 4)
	{
		this.sectionBeats = sectionBeats;
	}
}
