package states.substates;

import base.Conductor;
import base.MusicBeat.MusicBeatSubstate;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.Boyfriend;
import states.*;
import states.menus.*;

class GameOverSubstate extends MusicBeatSubstate
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var volume:Float = 1;

	public static var character:String = 'bf-dead';
	public static var deathSound:String = 'fnf_loss_sfx';
	public static var deathMusic:String = 'gameOver';
	public static var deathConfirm:String = 'gameOverEnd';
	public static var deathBPM:Int = 100;

	public static function resetGameOver()
	{
		character = 'bf-dead';
		deathSound = 'fnf_loss_sfx';
		deathMusic = 'gameOver';
		deathConfirm = 'gameOverEnd';
		deathBPM = 100;
	}

	public function new(x:Float, y:Float)
	{
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, character);
		add(bf);

		PlayState.boyfriend.destroy();

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		FlxG.camera.followLerp = 1;
		FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		Conductor.changeBPM(deathBPM);
		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
		
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			//FlxG.resizeWindow(1280, 720);
			//FlxG.scaleMode = new RatioScaleMode();

			FlxG.sound.music.stop();
			PlayState.deaths = 0;

			if (PlayState.isStoryMode)
			{
				Main.switchState(this, new StoryMenuState());
			}
			else
				Main.switchState(this, new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			FlxG.sound.playMusic(Paths.music(deathMusic), volume);

		if (PlayState.storyWeek == 7)
		{
			volume = 0.2;

			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			{
				FlxG.sound.play(Paths.sound('jeff/jeffGameover-' + FlxG.random.int(1, 25)), 1, false, null, true, function()
				{
					if (!isEnding) FlxG.sound.music.fadeIn(4, 0.2, 1);
				});
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(deathConfirm));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
