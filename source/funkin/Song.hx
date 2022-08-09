package funkin;

import funkin.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

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

typedef SwagMeta =
{
	var author:String;
	var assetModifier:String;
	var ?offset:Int;
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

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
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

		return parseJSONshit(rawJson, rawMeta);
	}

	public static function parseJSONshit(rawJson:String, rawMeta:String = 'meta'):SwagSong
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
