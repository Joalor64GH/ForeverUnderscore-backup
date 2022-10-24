package states.substates;

import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;
import base.*;
import base.CoolUtil;
import base.MusicBeat.MusicBeatSubstate;
import base.SongLoader.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.Alphabet;
import funkin.Highscore;
import states.*;
import states.menus.*;

class PauseSubstate extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var pauseMusic:FlxSound;

	var menuItems:Array<PauseItem> = [];
	var difficultyArray:Array<PauseItem> = [];

	var pauseItems:Array<PauseItem> = [
		new PauseItem('Resume', '${ForeverLocales.curLang.resumeSong}'),
		new PauseItem('Restart Song', '${ForeverLocales.curLang.restartSong}'),
		new PauseItem('Exit to Options', '${ForeverLocales.curLang.exitOptions}'),
		new PauseItem('Exit to menu', '${ForeverLocales.curLang.exitMenu}')
	];

	public static var toOptions:Bool = false;
	public static var levelPractice:FlxText;

	private var levelError:FlxText;
	private var language = ForeverLocales.curLang;
	private var mutex:Mutex;

	public function new(x:Float, y:Float)
	{
		super();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		// menu items set up!
		menuItems = pauseItems;

		for (i in CoolUtil.difficulties)
		{
			// check for existance of difficulty files, and then push said files to the difficulty array as an entry;
			var songName = CoolUtil.spaceToDash(PlayState.SONG.song);
			var diffString = Std.string(i);
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				difficultyArray.push(new PauseItem(diffString, diffString));
		}

		if (difficultyArray.length > 1) // no need to show the button if there's only a single difficulty;
		{
			menuItems.insert(2, new PauseItem('Change Difficulty', '${language.changeDiff}'));
			difficultyArray.push(new PauseItem('BACK', '${language.backButton}'));
		}

		#if debug
		if (!PlayState.isStoryMode)
			menuItems.insert(2, 'Open Editors');
		#end

		if (PlayState.chartingMode)
		{
			menuItems.insert(3, new PauseItem('Leave Charting Mode', '${language.leaveChartingMode}'));
			menuItems.insert(4, new PauseItem('Toggle Practice Mode', '${language.togglePractice}'));
			menuItems.insert(5, new PauseItem('Toggle Autoplay', '${language.toggleAutoplay}'));
		}

		// pause music, bg, and texts
		var pauseSong = Init.trueSettings.get('Pause Song');

		mutex = new Mutex();
		Thread.create(function(){
			mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(Paths.music('menus/pause/$pauseSong/$pauseSong'), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);
			mutex.release();
		});

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song) + ' [' + language.difficultyNames[PlayState.storyDifficulty] + ']';
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font('vcr'), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelAuthor:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelAuthor.text += '${language.songByTxt} ' + PlayState.SONG.author;
		levelAuthor.scrollFactor.set();
		levelAuthor.setFormat(Paths.font('vcr'), 32);
		levelAuthor.updateHitbox();
		add(levelAuthor);

		var levelDeaths:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelDeaths.text += '${language.blueballedTxt} ' + PlayState.deaths;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(Paths.font('vcr'), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		levelPractice = new FlxText(20, 15 + 96, 0, "PRACTICE MODE", 32);
		levelPractice.scrollFactor.set();
		levelPractice.setFormat(Paths.font('vcr'), 32);
		levelPractice.updateHitbox();
		levelPractice.visible = PlayState.practiceMode;
		add(levelPractice);

		levelError = new FlxText(20, 15 + 102, 0, '', 32);
		levelError.scrollFactor.set();
		levelError.setFormat(Paths.font('vcr'), 32);
		levelError.updateHitbox();
		add(levelError);

		levelInfo.alpha = 0;
		levelAuthor.alpha = 0;
		levelDeaths.alpha = 0;
		levelError.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelAuthor.x = FlxG.width - (levelAuthor.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);
		levelPractice.x = FlxG.width - (levelPractice.width + 20);
		levelError.x = FlxG.width - (levelError.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelAuthor, {alpha: 1, y: levelAuthor.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		reloadOptions();
	}

	function reloadOptions()
	{
		// kill and destroy all the existing items inside the item group;
		for (i in 0...grpMenuShit.members.length)
		{
			var existingItem = grpMenuShit.members[0];
			existingItem.kill();
			grpMenuShit.remove(existingItem, true);
			existingItem.destroy();
		}

		// generate the new menu items;
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i].displayName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection(0, false);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (pauseMusic != null && pauseMusic.playing) {
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}

		if (controls.UI_UP_P)
			changeSelection(-1);
		else if (controls.UI_DOWN_P)
			changeSelection(1);

		if (FlxG.mouse.wheel != 0)
			changeSelection(-1 * FlxG.mouse.wheel, false);

		if (controls.BACK || FlxG.mouse.justPressedRight)
			close();

		if (controls.ACCEPT || FlxG.mouse.justPressed)
		{
			var daSelected:String = menuItems[curSelected].name;

			if (menuItems == difficultyArray && daSelected != 'BACK' && difficultyArray.contains(menuItems[curSelected]))
			{
				var leSongRaw = PlayState.SONG.song.toLowerCase();
				var leSong = Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelected);

				try
				{
					PlayState.SONG = Song.loadSong(leSong, leSongRaw);
					PlayState.storyDifficulty = curSelected;
					disableCheats(true);
					Main.switchState(this, new PlayState());
				}
				catch (e)
				{
					levelError.text = "Uncaught Error: " + e;
					levelError.x = FlxG.width - (levelError.width + 20);
					levelError.alpha = 1;
					menuItems = pauseItems;
					reloadOptions();

					FlxTween.tween(levelError, {alpha: 0}, 2);
				}
				return;
			}

			switch (daSelected.toLowerCase())
			{
				case 'resume':
					close();
				case 'restart song':
					if (!PlayState.chartingMode)
						disableCheats(false);
					else
						disableCheats(true);
					Main.switchState(this, new PlayState());
				case "change difficulty":
					menuItems = difficultyArray;
					reloadOptions();
				case 'exit to options':
					toOptions = true;
					disableCheats(true);
					Main.switchState(this, new OptionsMenuState());
				case 'exit to menu':
					Conductor.stopMusic();
					PlayState.deaths = 0;
					disableCheats(true);

					// CoolUtil.difficulties = CoolUtil.baseDifficulties;

					if (PlayState.isStoryMode)
						Main.switchState(this, new StoryMenuState());
					else
						Main.switchState(this, new FreeplayMenuState());

				case 'open editors':
					EditorMenuSubstate.fromPause = true;
					openSubState(new EditorMenuSubstate(false, true));

				case 'leave charting mode':
					disableCheats(true);
					PlayState.chartingMode = false;
					Main.switchState(this, new PlayState());
				case 'toggle practice mode':
					PlayState.preventScoring = true;
					PlayState.practiceMode = !PlayState.practiceMode;
					levelPractice.visible = PlayState.practiceMode;
				case 'toggle autoplay':
					PlayState.preventScoring = true;
					PlayState.bfStrums.autoplay = !PlayState.bfStrums.autoplay;
					PlayState.uiHUD.autoplayMark.visible = PlayState.bfStrums.autoplay;
					PlayState.uiHUD.autoplayMark.alpha = 1;
					PlayState.uiHUD.autoplaySine = 0;
				case 'back':
					menuItems = pauseItems;
					reloadOptions();
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	public static function disableCheats(scoringToo:Bool = false)
	{
		PlayState.practiceMode = false;
		PlayState.bfStrums.autoplay = false;
		PlayState.uiHUD.autoplayMark.visible = false;

		if (scoringToo)
			PlayState.preventScoring = false;

		levelPractice.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true):Void
	{
		curSelected += change;
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

/*
	could be better but whatever
*/
class PauseItem
{
	public var name:String;
	public var displayName:String;

	public function new(name:String, displayName:String)
	{
		this.name = name;
		this.displayName = displayName;
	}
}
