package;

import sys.FileSystem;
import base.Conductor;
import base.SongLoader.LegacySection;
import dependency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import funkin.*;
import funkin.Strumline.Receptor;
import funkin.Timings;
import funkin.ui.menu.*;
import states.PlayState;

using StringTools;

typedef SplashDataDef =
{
	var file:Null<String>;
	var type:Null<String>;
	var width:Null<Int>;
	var height:Null<Int>;
	var offsets:Null<Array<Int>>;
}

/**
	Forever Assets is a class that manages the different asset types, basically a compilation of switch statements that are
	easy to edit for your own needs. Most of these are just static functions that return information
**/
class ForeverAssets
{
	//
	public static function generateCombo(asset:String, number:String, allSicks:Bool, group:FlxTypedGroup<FNFSprite>, assetModifier:String = 'base',
			changeableSkin:String = 'default', baseLibrary:String, negative:Bool, createdColor:FlxColor, scoreInt:Int, ?debug:Bool = false):FNFSprite
	{
		var width:Int = 100;
		var height:Int = 140;
		if (assetModifier == 'pixel')
		{
			width = 10;
			height = 12;
		}

		var parsedNumber:Null<Int> = Std.parseInt(number);
		var combo:FNFSprite;
		if (group != null)
			combo = group.recycle(FNFSprite);
		else
			combo = new FNFSprite();
		combo.loadGraphic(Paths.image(ForeverTools.returnSkin(asset, assetModifier, changeableSkin, baseLibrary)), true, width, height);
		combo.animation.add('combo', [(parsedNumber != null ? parsedNumber + 1 : 0) + (!allSicks ? 0 : 11)], 0, false);

		combo.alpha = 1;
		combo.zDepth = -Conductor.songPosition;
		combo.animation.play('combo');
		combo.screenCenter();
		combo.x += (43 * scoreInt) + 20;
		combo.y += 60;

		if (Init.getSetting('Fixed Judgements') && !debug)
		{
			combo.x += Init.comboOffset[0];
			combo.y += Init.comboOffset[1];
		}

		combo.color = FlxColor.WHITE;
		if (negative)
			combo.color = createdColor;

		if (assetModifier == 'pixel')
		{
			combo.antialiasing = false;
			combo.setGraphicSize(Std.int(combo.frameWidth * PlayState.daPixelZoom));
		}
		else
		{
			combo.antialiasing = !Init.getSetting('Disable Antialiasing');
			combo.setGraphicSize(Std.int(combo.frameWidth * 0.5));
		}
		combo.updateHitbox();

		if (combo != null)
		{
			if (Init.getSetting('Judgement Stacking') && !debug)
			{
				combo.acceleration.y = FlxG.random.int(100, 200) * Conductor.playbackRate * Conductor.playbackRate;
				combo.velocity.y = -FlxG.random.int(140, 160) * Conductor.playbackRate;
				combo.velocity.x = FlxG.random.float(-5, 5) * Conductor.playbackRate;

				FlxTween.tween(combo, {alpha: 0}, (Conductor.stepCrochet * 2) / 1000 / Conductor.playbackRate, {
					onComplete: function(tween:FlxTween)
					{
						combo.kill();
					},
					startDelay: (Conductor.crochet) / 1000 / Conductor.playbackRate
				});
			}
			else if (!debug)
			{
				FlxTween.tween(combo, {y: combo.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			}
		}

		return combo;
	}

	public static function generateRating(newRating:String, perfect:Bool, lateHit:Bool, group:FlxTypedGroup<FNFSprite>, assetModifier:String = 'base',
			changeableSkin:String = 'default', baseLibrary:String, ?debug:Bool = false):FNFSprite
	{
		var rating:FNFSprite;
		if (group != null)
			rating = group.recycle(FNFSprite);
		else
			rating = new FNFSprite();
		rating.loadGraphic(Paths.image(ForeverTools.returnSkin('judgements', assetModifier, changeableSkin, baseLibrary)), true,
			assetModifier == 'pixel' ? 72 : 500, assetModifier == 'pixel' ? 32 : 163);

		rating.animation.add(newRating, [
			Std.int((Timings.judgementsMap.get(newRating)[0] * 2) + (perfect ? 0 : 2) + (lateHit ? 1 : 0))
		], (assetModifier == 'pixel' ? 12 : 24), false);

		rating.alpha = 1;
		rating.zDepth = -Conductor.songPosition;
		rating.screenCenter();
		rating.animation.play(newRating);
		rating.y -= 60;
		rating.x = (FlxG.width * 0.55) - 40;

		if (Init.getSetting('Fixed Judgements') && !debug)
		{
			rating.x += Init.ratingOffset[0];
			rating.y += Init.ratingOffset[1];
		}

		if (assetModifier == 'pixel')
		{
			rating.antialiasing = false;
			rating.setGraphicSize(Std.int(rating.frameWidth * PlayState.daPixelZoom * 0.7));
		}
		else
		{
			rating.antialiasing = !Init.getSetting('Disable Antialiasing');
			rating.setGraphicSize(Std.int(rating.frameWidth * 0.7));
		}
		rating.updateHitbox();

		if (rating != null)
		{
			if (Init.getSetting('Judgement Stacking') && !debug)
			{
				rating.velocity.y = -FlxG.random.int(140, 175) * Conductor.playbackRate;
				rating.velocity.x = -FlxG.random.int(0, 10) * Conductor.playbackRate;
				rating.acceleration.y = 550 * Conductor.playbackRate * Conductor.playbackRate;

				FlxTween.tween(rating, {alpha: 0}, (Conductor.stepCrochet) / 1000, {
					onComplete: function(tween:FlxTween)
					{
						rating.kill();
					},
					startDelay: ((Conductor.crochet + Conductor.stepCrochet * 2) / 1000 / Conductor.playbackRate)
				});
			}
		}

		return rating;
	}

	public static function generateNoteSplashes(asset:String, group:FlxTypedSpriteGroup<NoteSplash>, assetModifier:String = 'base', baseLibrary:String,
			noteData:Int):NoteSplash
	{
		//
		var tempSplash:NoteSplash = group.recycle(NoteSplash);
		tempSplash.noteData = noteData;

		var changeableSkin:String = Init.getSetting("Note Skin");

		// will eventually change this in favor of customizable splashes through scripts;
		var path = Paths.getPreloadPath('images/$baseLibrary/$changeableSkin/$assetModifier/splashData.json');

		var rawJson = null;
		if (!FileSystem.exists(path))
		{
			path = Paths.getPreloadPath('images/$baseLibrary/default/$assetModifier/splashData.json');
		}
		rawJson = sys.io.File.getContent(path);

		var splashJson:SplashDataDef = cast haxe.Json.parse(rawJson);

		if (splashJson.file != null)
			asset = splashJson.file;

		switch (assetModifier)
		{
			case 'pixel':
				if (asset == null)
					asset = 'splash-pixel';

				var width = splashJson.width;
				var height = splashJson.height;

				if (splashJson.width == null)
					width = 34;
				if (splashJson.height == null)
					height = 34;

				switch (splashJson.type)
				{
					case "sparrow":
						tempSplash.frames = Paths.getSparrowAtlas(ForeverTools.returnSkin(asset, assetModifier, changeableSkin, baseLibrary));

						// week 7 format
						tempSplash.animation.addByPrefix('anim1', 'note impact 1 ' + Receptor.arrowCol[noteData], 24, false);
						tempSplash.animation.addByPrefix('anim2', 'note impact 2 ' + Receptor.arrowCol[noteData], 24, false);

						tempSplash.animation.addByPrefix('anim1', 'note impact 1  blue', 24, false); // HE DID IT AGAIN MY BOYS;

						// psych format
						tempSplash.animation.addByPrefix('anim1', 'note splash ' + Receptor.arrowCol[noteData] + ' 1', 24, false);
						tempSplash.animation.addByPrefix('anim2', 'note splash ' + Receptor.arrowCol[noteData] + ' 2', 24, false);
						tempSplash.updateHitbox();

					default:
						tempSplash.loadGraphic(Paths.image(ForeverTools.returnSkin(asset, assetModifier, changeableSkin, baseLibrary)), true, width, height);
						tempSplash.animation.add('anim1', [noteData, 4 + noteData, 8 + noteData, 12 + noteData], 24, false);
						tempSplash.animation.add('anim2', [16 + noteData, 20 + noteData, 24 + noteData, 28 + noteData], 24, false);
						tempSplash.animation.play('anim1');
						tempSplash.setGraphicSize(Std.int(tempSplash.width * PlayState.daPixelZoom));
				}

			default:
				if (asset == null)
					asset = 'noteSplashes';

				var width = splashJson.width;
				var height = splashJson.height;

				if (splashJson.width == null)
					width = 210;
				if (splashJson.height == null)
					height = 210;

				switch (splashJson.type)
				{
					case "sparrow":
						tempSplash.frames = Paths.getSparrowAtlas(ForeverTools.returnSkin(asset, assetModifier, changeableSkin, baseLibrary));

						// week 7 format
						tempSplash.animation.addByPrefix('anim1', 'note impact 1 ' + Receptor.arrowCol[noteData], 24, false);
						tempSplash.animation.addByPrefix('anim2', 'note impact 2 ' + Receptor.arrowCol[noteData], 24, false);

						tempSplash.animation.addByPrefix('anim1', 'note impact 1  blue', 24, false); // HE DID IT AGAIN MY BOYS;

						// psych format
						tempSplash.animation.addByPrefix('anim1', 'note splash ' + Receptor.arrowCol[noteData] + ' 1', 24, false);
						tempSplash.animation.addByPrefix('anim2', 'note splash ' + Receptor.arrowCol[noteData] + ' 2', 24, false);
						tempSplash.updateHitbox();

					default:
						tempSplash.loadGraphic(Paths.image(ForeverTools.returnSkin(asset, assetModifier, changeableSkin, baseLibrary)), true, width, height);
						tempSplash.animation.add('anim1', [
							(noteData * 2 + 1),
							8 + (noteData * 2 + 1),
							16 + (noteData * 2 + 1),
							24 + (noteData * 2 + 1),
							32 + (noteData * 2 + 1)
						], 24, false);
						tempSplash.animation.add('anim2', [
							(noteData * 2),
							8 + (noteData * 2),
							16 + (noteData * 2),
							24 + (noteData * 2),
							32 + (noteData * 2)
						], 24, false);
				}
		}

		if (splashJson.offsets == null)
		{
			tempSplash.addOffset('anim1', -20, -10);
			tempSplash.addOffset('anim2', -20, -10);
		}
		else
		{
			tempSplash.addOffset('anim1', splashJson.offsets[0], splashJson.offsets[1]);
			tempSplash.addOffset('anim2', splashJson.offsets[2], splashJson.offsets[3]);
		}

		tempSplash.animation.play('anim1', true);

		group.sort(FNFSprite.depthSorting, FlxSort.DESCENDING);

		return tempSplash;
	}

	public static function generateUIArrows(x:Float, y:Float, ?staticArrowType:Int = 0, framesArgument:String = 'NOTE_assets', assetModifier:String):Receptor
	{
		var newStaticArrow:Receptor = new Receptor(x, y, staticArrowType);
		switch (assetModifier)
		{
			case 'pixel':
				newStaticArrow.loadGraphic(Paths.image(ForeverTools.returnSkin('arrows-pixels', assetModifier, Init.getSetting("Note Skin"),
					'noteskins/notes')), true, 17, 17);
				newStaticArrow.animation.add('static', [staticArrowType]);
				newStaticArrow.animation.add('pressed', [4 + staticArrowType, 8 + staticArrowType], 12, false);
				newStaticArrow.animation.add('confirm', [12 + staticArrowType, 16 + staticArrowType], 24, false);

				newStaticArrow.setGraphicSize(Std.int(newStaticArrow.width * PlayState.daPixelZoom));
				newStaticArrow.updateHitbox();
				newStaticArrow.antialiasing = false;

				newStaticArrow.addOffset('static', -67, -50);
				newStaticArrow.addOffset('pressed', -67, -50);
				newStaticArrow.addOffset('confirm', -67, -50);

			case 'chart editor':
				newStaticArrow.loadGraphic(Paths.image('menus/chart/note_array'), true, 157, 156);
				newStaticArrow.animation.add('static', [staticArrowType]);
				newStaticArrow.animation.add('pressed', [16 + staticArrowType], 12, false);
				newStaticArrow.animation.add('confirm', [4 + staticArrowType, 8 + staticArrowType, 16 + staticArrowType], 24, false);

				newStaticArrow.addOffset('static');
				newStaticArrow.addOffset('pressed');
				newStaticArrow.addOffset('confirm');

			default:
				// probably gonna revise this and make it possible to add other arrow types but for now it's just pixel and normal
				var stringSect:String = '';
				// call arrow type I think
				stringSect = Receptor.arrowDir[staticArrowType];

				newStaticArrow.frames = Paths.getSparrowAtlas(ForeverTools.returnSkin('$framesArgument', assetModifier, Init.getSetting("Note Skin"),
					'noteskins/notes'));

				newStaticArrow.animation.addByPrefix('static', 'arrow' + stringSect.toUpperCase());
				newStaticArrow.animation.addByPrefix('pressed', stringSect + ' press', 24, false);
				newStaticArrow.animation.addByPrefix('confirm', stringSect + ' confirm', 24, false);

				newStaticArrow.antialiasing = !Init.getSetting('Disable Antialiasing');
				newStaticArrow.setGraphicSize(Std.int(newStaticArrow.width * 0.7));

				// set little offsets per note!
				// so these had a little problem honestly and they make me wanna off(set) myself so the middle notes basically
				// have slightly different offsets than the side notes (which have the same offset)

				var pressCenterOffsets:Array<Int> = [0, 0];
				var centerOffsets:Array<Int> = [2, 2];

				switch (staticArrowType)
				{
					case 0:
						pressCenterOffsets = [-2, -2];
						centerOffsets = [1, 1];
					case 1:
						pressCenterOffsets = [-2, -3];
						centerOffsets = [1, 4];
					case 3:
						pressCenterOffsets = [0, -1];
						centerOffsets = [-1, 2];
				}

				// newStaticArrow.addOffset('static');
				newStaticArrow.addOffset('pressed', -2 + pressCenterOffsets[0], -2 + pressCenterOffsets[1]);
				newStaticArrow.addOffset('confirm', 36 + centerOffsets[0], 36 + centerOffsets[1]);
		}

		return newStaticArrow;
	}

	/**
		Notes!
	**/
	public static function generateArrow(assetModifier, strumTime, noteData, noteAlt, ?isSustain:Bool = false, ?prevNote:Note = null, noteType:Int = 0):Note
	{
		var newNote:Note;
		var changeableSkin:String = Init.getSetting("Note Skin");
		// gonna improve the system eventually
		if (changeableSkin.startsWith('quant'))
			newNote = Note.returnQuantNote(assetModifier, strumTime, noteData, noteAlt, isSustain, prevNote, noteType);
		else
			newNote = Note.returnDefaultNote(assetModifier, strumTime, noteData, noteAlt, isSustain, prevNote, noteType);

		// hold note shit
		if (isSustain && prevNote != null)
		{
			// set note offset
			if (prevNote.isSustain)
				newNote.noteVisualOffset = prevNote.noteVisualOffset;
			else // calculate a new visual offset based on that note's width and newnote's width
				newNote.noteVisualOffset = ((prevNote.width / 2) - (newNote.width / 2));
		}

		return newNote;
	}

	/**
		Checkmarks!
	**/
	public static function generateCheckmark(x:Float, y:Float, asset:String, assetModifier:String = 'base', changeableSkin:String = 'default',
			baseLibrary:String)
	{
		var newCheckmark:Checkmark = new Checkmark(x, y);
		newCheckmark.frames = Paths.getSparrowAtlas(ForeverTools.returnSkin(asset, assetModifier, changeableSkin, baseLibrary));
		newCheckmark.antialiasing = !Init.getSetting('Disable Antialiasing');

		newCheckmark.animation.addByPrefix('false finished', 'uncheckFinished');
		newCheckmark.animation.addByPrefix('false', 'uncheck', 12, false);
		newCheckmark.animation.addByPrefix('true finished', 'checkFinished');
		newCheckmark.animation.addByPrefix('true', 'check', 12, false);
		newCheckmark.setGraphicSize(Std.int(newCheckmark.width * 0.7));
		newCheckmark.updateHitbox();
		newCheckmark.addOffset('false', 45, 5);
		newCheckmark.addOffset('true', 45, 5);
		newCheckmark.addOffset('true finished', 45, 5);
		newCheckmark.addOffset('false finished', 45, 5);
		return newCheckmark;
	}
}
