package funkin;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import haxe.Json;
import sys.io.File;
import base.*;
import base.SongLoader.LegacySection;
import base.SongLoader.Song;
import funkin.compat.PsychChar;
import dependency.FNFSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.util.FlxSort;
import states.PlayState;
import states.substates.GameOverSubstate;
import funkin.background.TankmenBG;

using StringTools;

class Character extends FNFSprite
{
	public var curCharacter:String = 'bf';

	public var icon:String = null;

	public var holdTimer:Float = 0;

	public var barColor:Array<Float> = [];
	public var animationNotes:Array<Dynamic> = [];
	public var idlePos:Array<Float> = [0, 0];

	public var cameraOffset:FlxPoint;
	public var characterOffset:FlxPoint;

	public var debugMode:Bool = false;
	public var isPlayer:Bool = false;
	public var quickDancer:Bool = false;

	public var characterScripts:Array<ScriptHandler> = [];

	public var idleSuffix:String = '';

	public var stunned:Bool = false; // whether the Character is dead or not

	public var isHolding:Bool = false;

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

		cameraOffset = new FlxPoint(0, 0);
		characterOffset = new FlxPoint(0, 0);

		setCharacter(x, y, character);
	}

	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		curCharacter = character;

		if (icon == null)
			icon = character;

		switch (character)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}

		psychChar = ForeverTools.fileExists('characters/$character/' + character + '.json');

		switch (character)
		{
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
					generateBoyfriend();
				}
		}

		recalcDance();
		dance();

		if (isPlayer) // reverse player flip
			flipX = !flipX;

		if (Init.getSetting('Disable Antialiasing'))
			antialiasing = false;

		setPosition(x, y);
		this.x += characterOffset.x;
		this.y += (characterOffset.y - (frameHeight * scale.y));

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
		for (i in characterScripts)
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

		for (i in characterScripts)
			i.call('postUpdate', [elapsed]);

		super.update(elapsed);

		var isSinging:Bool = (animation.curAnim.name.startsWith('sing') && !animation.curAnim.name.endsWith('miss'));
		if (!debugMode && isSinging && isHolding && animation.curAnim.numFrames > 1 && animation.curAnim.curFrame > 1 && !animation.curAnim.finished)
			animation.curAnim.curFrame = 0;
	}

	var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode)
		{
			isHolding = false;
			if (!skipDance && !specialAnim && animation.curAnim != null)
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
		animationNotes.sort(function(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
		{
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
		});
		TankmenBG.animationNotes = animationNotes;
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

	/**
	 * [Generates a Character in the Forever Engine Underscore Format]
	 * @param char returns the character that should be generated
	 */
	function generateBaseChar(char:String = 'bf')
	{
		var pushedScripts:Array<String> = [];
		var extensions = ['hx', 'hxs', 'hscript', 'hxc'];
		var paths:Array<String> = ['characters/$char/config', 'characters/$char/config'];

		for (i in paths)
		{
			for (j in extensions)
			{
				if (j != null)
				{
					if (ForeverTools.fileExists(i + '.$j') && !pushedScripts.contains(i + '.$j'))
					{
						var script:ScriptHandler = new ScriptHandler(Paths.getPath(i + '.$j', TEXT));

						if (script.interp == null)
						{
							trace("Something terrible occured! Skipping.");
							continue;
						}

						characterScripts.push(script);
						pushedScripts.push(i + '.$j');
					}
				}
			}
		}

		var tex:FlxFramesCollection;

		var spriteType = "SparrowAtlas";

		if (ForeverTools.fileExists('characters/$char/$char.txt', TEXT))
			spriteType = "PackerAtlas";
		else if (ForeverTools.fileExists('characters/$char/$char.json', TEXT))
			spriteType = "JsonAtlas";
		else
			spriteType = "SparrowAtlas";

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
			characterOffset.set(x, y);
		});

		setVar('setCamOffsets', function(?x:Float = 0, ?y:Float = 0)
		{
			cameraOffset.set(x, y);
		});

		setVar('setScale', function(?x:Float = 1, ?y:Float = 1)
		{
			scale.set(x, y);
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
		if (PlayState.SONG != null)
			setVar('songName', PlayState.SONG.song.toLowerCase());
		setVar('flipLeftRight', flipLeftRight);

		for (i in characterScripts)
			i.call('loadAnimations', []);

		if (animation.getByName('danceLeft') != null)
			playAnim('danceLeft');
		else
			playAnim('idle');
	}

	public function setVar(key:String, value:Dynamic)
	{
		var allSucceed:Bool = true;
		if (characterScripts != null)
		{
			for (i in characterScripts)
			{
				i.set(key, value);

				if (!i.exists(key))
				{
					trace('${i.scriptFile} failed to set $key for its interpreter, continuing.');
					allSucceed = false;
					continue;
				}
			}
		}
		return allSucceed;
	}

	public function noteHit(dunceNote:funkin.Note)
	{
		if (characterScripts != null)
		{
			for (i in characterScripts)
				i.call('noteHit', [dunceNote]);
		}
	}

	public var psychAnimationsArray:Array<PsychAnimArray> = [];

	/**
	 * [Generates a Character in the Psych Engine Format, as a Compatibility Layer for them]
	 * [@author Shadow_Mario_]
	 * @param char returns the character that should be generated
	 */
	function generatePsychChar(char:String = 'bf')
	{
		var rawJson = File.getContent(Paths.getPath('characters/$char/' + char + '.json'));

		var json:PsychEngineChar = cast Json.parse(rawJson);

		var tex:FlxFramesCollection;

		var spriteType:String = "SparrowAtlas";
		var characterPath:String = 'characters/$char/' + json.image.replace('characters/', '');

		if (ForeverTools.fileExists('$characterPath.txt', TEXT))
			spriteType = "PackerAtlas";
		else
			spriteType = "SparrowAtlas";
		/*
			else if (ForeverTools.fileExists('$characterPath.json', TEXT))
				spriteType = "JsonAtlas";
		 */

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
		characterOffset.set(json.position[0], json.position[1]);
		cameraOffset.set(json.camera_position[0], json.camera_position[1]);

		// icon = json.healthicon;
		barColor = json.healthbar_colors;
		singDuration = json.sing_duration;
		characterOffset.set(json.position[0], json.position[1]);
		cameraOffset.set(json.camera_position[0], json.camera_position[1]);
		if (json.scale != 1)
		{
			setGraphicSize(Std.int(width * json.scale));
			updateHitbox();
		}

		if (animation.getByName('danceLeft') != null)
			playAnim('danceLeft');
		else
			playAnim('idle');
	}

	function generateBoyfriend()
	{
		frames = Paths.getSparrowAtlas('bf', 'characters/bf');

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

		playAnim('idle');

		flipX = true;

		characterOffset.x = 70;
		curCharacter = 'placeholder';
	}
}
