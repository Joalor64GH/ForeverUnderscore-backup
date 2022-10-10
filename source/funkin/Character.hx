package funkin;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import base.*;
import base.SongLoader.LegacySection;
import base.SongLoader.LegacySong;
import base.SongLoader.Song;
import base.data.PsychChar;
import base.data.SuperChar;
import dependency.FNFSprite;
import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxSort;
import openfl.Assets;
import openfl.utils.Assets as OpenFlAssets;
import states.PlayState;
import states.substates.GameOverSubstate;
import funkin.background.TankmenBG;
import funkin.ui.HealthIcon;

using StringTools;

class Character extends FNFSprite
{
	public var character:String;

	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var adjustPos:Bool = true;

	public var icon:String;

	public var barColor:Array<Float> = [];
	public var animationNotes:Array<Dynamic> = [];
	public var idlePos:Array<Float> = [0, 0];

	public var charOffsets:Array<Float> = [0, 0];
	public var camOffsets:Array<Float> = [0, 0];
	public var scales:Array<Float> = [0, 0];

	public var debugMode:Bool = false;
	public var isPlayer:Bool = false;
	public var quickDancer:Bool = false;

	public var charScripts:Array<ScriptHandler> = [];

	public var idleSuffix:String = '';

	public var stunned:Bool = false; // whether the Character is dead or not

	public var bopSpeed:Int = 2;

	// FOR PSYCH COMPATIBILITY
	public var danceIdle:Bool = false; // Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;
	public var specialAnim:Bool = false;
	public var singDuration:Float = 4; // Multiplier of how long a character holds the sing pose
	public var heyTimer:Float = 0;
	public var psychChar:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?isPlayer:Bool = false, ?character:String = 'bf')
	{
		super(x, y);
		this.isPlayer = isPlayer;

		setCharacter(x, y, character);
	}

	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		this.character = character;

		if (icon == null)
			icon = character;

		psychChar = ForeverTools.fileExists('characters/$character/' + character + '.json', TEXT);

		switch (character)
		{
			// hardcoded (example, in case you want to hardcode characters)
			/*
				case 'bf-og':
					frames = Paths.getSparrowAtlas('characters/base/BOYFRIEND');
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('scared', 'BF idle shaking', 24);
					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
					playAnim('idle');
					flipX = true;
			 */
			default:
				try
				{
					if (psychChar)
						generatePsychChar(character);
					else
						generateBaseChar(character);
				}
				catch (e)
				{
					trace('$character is invalid!');
					generateBaseChar('bf');
				}
		}

		recalcDance();
		dance();

		switch (character)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}

		setPosition(x, y);
		if (adjustPos)
		{
			this.x += charOffsets[0];
			this.y += (charOffsets[1] - (frameHeight * scale.y));
		}

		return this;
	}

	function flipLeftRight()
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		for (i in charScripts)
			i.call('update', [elapsed]);

		/**
		 * Special Animations Code.
		 * @author: Shadow_Mario_
		**/

		if (!debugMode && animation.curAnim != null)
		{
			if (heyTimer > 0)
			{
				heyTimer -= elapsed * Conductor.playbackRate;
				if (heyTimer <= 0)
				{
					if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			}
			else if (specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			switch (curCharacter)
			{
				case 'pico-speaker':
					if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
					{
						var noteData:Int = 1;
						if (animationNotes[0][1] > 2)
							noteData = 3;

						noteData += FlxG.random.int(0, 1);
						playAnim('shoot' + noteData, true);
						animationNotes.shift();
					}
					if (animation.curAnim.finished)
						playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}

			if (!skipDance && !specialAnim && !debugMode)
			{
				if (!isPlayer)
				{
					if (animation.curAnim.name.startsWith('sing'))
						holdTimer += elapsed;
					if (holdTimer >= Conductor.stepCrochet * (0.0011 / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1)) * singDuration)
					{
						holdTimer = 0;
						dance();
					}
				}
				else
				{
					if (animation.curAnim.name.startsWith('sing'))
						holdTimer += elapsed;
					else
						holdTimer = 0;
				}
			}

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
				dance();

			if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				playAnim('danceRight');
			if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
				playAnim('danceLeft');

			if (animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}

			if (animation.curAnim.finished && animation.curAnim.name == 'idle')
			{
				if (animation.getByName('idlePost') != null)
					animation.play('idlePost', true, false, 0);
			}
		}

		for (i in charScripts)
			i.call('postUpdate', [elapsed]);

		super.update(elapsed);
	}

	var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode && !skipDance && !specialAnim && animation.curAnim != null)
		{
			if (danceIdle)
			{
				danced = !danced;
				if (danced)
					playAnim('danceRight$idleSuffix', forced);
				else
					playAnim('danceLeft$idleSuffix', forced);
			}
			else
				playAnim('idle$idleSuffix', forced);
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	function loadMappedAnims()
	{
		var sections:Array<LegacySection> = Song.loadSong('picospeaker', PlayState.SONG.song.toLowerCase()).notes;
		for (section in sections)
		{
			for (note in section.sectionNotes)
			{
				animationNotes.push(note);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		animationNotes.sort(function(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
		{
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
		});
	}

	private var settingCharacterUp:Bool = true;

	/**
	 * mostly used for Psych Engine Characters;
	 * @author Shadow_Mario_
	**/
	public function recalcDance()
	{
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if (settingCharacterUp)
		{
			bopSpeed = (danceIdle ? 1 : 2);
		}
		else if (lastDanceIdle != danceIdle)
		{
			var calc:Float = bopSpeed;
			if (danceIdle)
				calc /= 2;
			else
				calc *= 2;

			bopSpeed = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	function generateBaseChar(char:String = 'bf')
	{
		var scripts:Array<String> = ['characters/$char/config.hx', 'characters/$char/config.hxs'];

		var pushedScripts:Array<String> = [];

		for (i in scripts)
		{
			if (ForeverTools.fileExists(i) && !pushedScripts.contains(i))
			{
				var script:ScriptHandler = new ScriptHandler(Paths.getTextFromFile(i));

				if (script.interp == null)
				{
					trace("Something terrible occured! Skipping.");
					continue;
				}

				charScripts.push(script);
				pushedScripts.push(i);
			}
		}

		var tex:FlxFramesCollection;

		var spriteType = "SparrowAtlas";

		if (ForeverTools.fileExists('characters/$char/$char.txt', TEXT))
			spriteType = "PackerAtlas";
		else if (ForeverTools.fileExists('characters/$char/$char.json', TEXT))
			spriteType = "JsonAtlas";

		// trace('Atlas Type: ' + spriteType + ' for Character: ' + char);

		switch (spriteType)
		{
			case "PackerAtlas":
				tex = Paths.getPackerAtlas(char, 'characters/$char');
			case "JsonAtlas":
				tex = Paths.getJsonAtlas(char, 'characters/$char');
			default:
				tex = Paths.getSparrowAtlas(char, 'characters/$char');
		}

		frames = tex;

		// trace(interp, script);
		setVar('addByPrefix', function(name:String, prefix:String, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByPrefix(name, prefix, frames, loop);
		});

		setVar('addByIndices', function(name:String, prefix:String, indices:Array<Int>, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByIndices(name, prefix, indices, "", frames, loop);
		});

		setVar('addOffset', function(?name:String = "idle", ?x:Float = 0, ?y:Float = 0)
		{
			addOffset(name, x, y);
			if (name == 'idle')
				idlePos = [x, y];
		});

		setVar('set', function(name:String, value:Dynamic)
		{
			Reflect.setProperty(this, name, value);
		});

		setVar('setSingDuration', function(amount:Int)
		{
			singDuration = amount;
		});

		setVar('setOffsets', function(?x:Float = 0, ?y:Float = 0)
		{
			charOffsets = [x, y];
		});

		setVar('setCamOffsets', function(?x:Float = 0, ?y:Float = 0)
		{
			camOffsets = [x, y];
		});

		setVar('setScale', function(?x:Float = 1, ?y:Float = 1)
		{
			scales = [x, y];
			scale.set(scales[0], scales[1]);
		});

		setVar('setIcon', function(swag:String = 'face') icon = swag);

		setVar('quickDancer', function(quick:Bool = false)
		{
			quickDancer = quick;
		});

		setVar('setBarColor', function(rgb:Array<Float>)
		{
			if (barColor != null)
				barColor = rgb;
			else
				barColor = [161, 161, 161];
			return true;
		});

		setVar('setDeathChar',
			function(char:String = 'bf-dead', lossSfx:String = 'fnf_loss_sfx', song:String = 'gameOver', confirmSound:String = 'gameOverEnd', bpm:Int)
			{
				GameOverSubstate.character = char;
				GameOverSubstate.deathSound = lossSfx;
				GameOverSubstate.deathMusic = song;
				GameOverSubstate.deathConfirm = confirmSound;
				GameOverSubstate.deathBPM = bpm;
			});

		setVar('get', function(variable:String)
		{
			return Reflect.getProperty(this, variable);
		});

		setVar('setGraphicSize', function(width:Int = 0, height:Int = 0)
		{
			setGraphicSize(width, height);
			updateHitbox();
		});

		setVar('playAnim', function(name:String, ?force:Bool = false, ?reversed:Bool = false, ?frames:Int = 0)
		{
			playAnim(name, force, reversed, frames);
		});

		setVar('isPlayer', isPlayer);
		setVar('songName', PlayState.SONG.song.toLowerCase());
		setVar('flipLeftRight', flipLeftRight);

		for (i in charScripts)
			i.call('loadAnimations', []);

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !!flipX;
		}

		if (animation.getByName('danceLeft') != null)
			playAnim('danceLeft');
		else
			playAnim('idle');

		curCharacter = char;
	}

	public function setVar(key:String, value:Dynamic):Bool
	{
		for (i in charScripts)
			i.set(key, value);

		return true;
	}

	public function noteHit()
	{
		for (i in charScripts)
			i.call('noteHit', []);
	}

	public var psychAnimationsArray:Array<PsychAnimArray> = [];

	/*
		Compatibility Layer for Psych Engine Characters
		@author Shadow_Mario_
	 */
	function generatePsychChar(char:String = 'bf')
	{
		var path = Paths.getPath('characters/$char/' + char + '.json');

		var rawJson = File.getContent(path);

		var json:PsychEngineChar = cast Json.parse(rawJson);

		var tex:FlxFramesCollection;

		var spriteType:String = "SparrowAtlas";
		var characterPath:String = 'characters/$char/' + json.image.replace('characters/', '');

		if (ForeverTools.fileExists('$characterPath.txt', TEXT))
			spriteType = "PackerAtlas";
		/*
			else if (ForeverTools.fileExists('$characterPath.json', TEXT))
				spriteType = "JsonAtlas";
		 */

		// trace('Atlas Type: ' + spriteType + ' for Character: ' + char);

		switch (spriteType)
		{
			case "PackerAtlas":
				tex = Paths.getPackerAtlas(json.image.replace('characters/', ''), 'characters/$char');
			case "JsonAtlas":
				tex = Paths.getJsonAtlas(json.image.replace('characters/', ''), 'characters/$char');
			default:
				tex = Paths.getSparrowAtlas(json.image.replace('characters/', ''), 'characters/$char');
		}

		frames = tex;

		psychAnimationsArray = json.animations;
		for (anim in psychAnimationsArray)
		{
			var animAnim:String = '' + anim.anim;
			var animName:String = '' + anim.name;
			var animFps:Int = anim.fps;
			var animLoop:Bool = !!anim.loop; // Bruh
			var animIndices:Array<Int> = anim.indices;
			if (animIndices != null && animIndices.length > 0)
				animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
			else
				animation.addByPrefix(animAnim, animName, animFps, animLoop);

			if (anim.offsets != null && anim.offsets.length > 1)
				addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
		}
		flipX = json.flip_x;
		antialiasing = !json.no_antialiasing;
		charOffsets = json.position;
		camOffsets = json.camera_position;

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;
		}

		// icon = json.healthicon;
		barColor = json.healthbar_colors;
		singDuration = json.sing_duration;
		scale.set(json.scale, json.scale);
		updateHitbox();

		if (animation.getByName('danceLeft') != null)
			playAnim('danceLeft');
		else
			playAnim('idle');

		curCharacter = char;
	}
}
