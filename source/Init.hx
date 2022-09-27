import sys.FileSystem;
import base.CoolUtil;
import base.debug.Overlay;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import funkin.Highscore;
import funkin.PlayerSettings;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import states.*;

using StringTools;

/** 
	Enumerator for settingtypes
**/
enum SettingTypes
{
	Checkmark;
	Selector;
}

/**
	This is the initialisation class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
	A lot of this code is just going to be similar to the flixel templates' colorblind filters because I wanted to add support for those as I'll
	most likely need them for skater, and I think it'd be neat if more mods were more accessible.
**/
class Init extends FlxState
{
	/*
		Okay so here we'll set custom settings. As opposed to the previous options menu, everything will be handled in here with no hassle.
		This will read what the second value of the key's array is, and then it will categorise it, telling the game which option to set it to.

		0 - boolean, true or false checkmark
		1 - choose string
		2 - choose number (for fps so its low capped at 30)
		3 - offsets, this is unused but it'd bug me if it were set to 0
		might redo offset code since I didnt make it and it bugs me that it's hardcoded the the last part of the controls menu
	 */
	public static var FORCED = 'forced';
	public static var NOT_FORCED = 'not forced';

	public static var comboOffset:Array<Float> = [0, 0];
	public static var ratingOffset:Array<Float> = [0, 0];

	/**
		* hi, gabi (ghost) here, I know this is an odd place to put a comment but i'm gonna try to be more descriptive
		* in regardless to variables and such from now on
		* i think it's nice to explain how at least some of these work at least for the sake of clarity and for making
		* things somewhat easier for everyone

		* here is the main setting format if you want to create a new one
		* set it to the `gameSettings` map and you should be good to go

		* `'Name' => [param1, Type, 'Description', NOT_FORCED`]

		* param1 can be either `true` | `false`, or a string value, like `'bepis'` or something
		* type can be anything on the `SettingTypes` enum,
		* `FORCED` means the main game will hide that option and force it to stay on the default parameter
	**/
	//
	public static var gameSettings:Map<String, Dynamic> = [
		// GAMEPLAY;
		'Downscroll' => [
			false,
			Checkmark,
			'Whether to have the receptors vertically flipped in gameplay.',
			NOT_FORCED
		],
		'Centered Receptors' => [
			false,
			Checkmark,
			"Center your notes, and repositions the enemy's notes to the sides of the screen.",
			NOT_FORCED
		],
		'Hide Opponent Receptors' => [
			false,
			Checkmark,
			"Whether to hide the Opponent's Notes during gameplay.",
			NOT_FORCED
		],
		'Ghost Tapping' => [
			false,
			Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.",
			NOT_FORCED
		],
		"Hitsound Type" => ['default', Selector, 'Choose the Note Hitsound you prefer.', NOT_FORCED, ''],
		'Hitsound Volume' => [Checkmark, Selector, 'The volume for your Note Hitsounds.', NOT_FORCED],
		'Use Custom Note Speed' => [
			false,
			Checkmark,
			"Whether to override the song's scroll speed to use your own.",
			NOT_FORCED
		],
		'Scroll Speed' => [
			1,
			Selector,
			'Set your custom scroll speed for the Notes (NEEDS "Use Custom Note Speed" ENABLED).',
			NOT_FORCED
		],
		// TEXT;
		'Display Accuracy' => [
			true,
			Checkmark,
			'Whether to display your accuracy on the score bar during gameplay.',
			NOT_FORCED
		],
		'Skip Text' => [
			'freeplay only',
			Selector,
			'Decides whether to skip cutscenes and dialogue in gameplay. May be always, only in freeplay, or never.',
			NOT_FORCED,
			['never', 'freeplay only', 'always']
		],
		// META;
		'Auto Pause' => [
			true,
			Checkmark,
			'Whether to pause the game automatically if the window is unfocused.',
			NOT_FORCED
		],
		#if GAME_UPDATER
		'Check for Updates' => [
			true,
			Checkmark,
			"Whether to check for updates when opening the game.",
			NOT_FORCED
		],
		#end
		'GPU Rendering' => [
			false,
			Checkmark,
			"Whether the game should use your GPU to render images. [EXPERIMENTAL, takes effect after restart]",
			NOT_FORCED
		],
		'Menu Song' => [
			'freakyMenu',
			Selector,
			'Which song should we use for the Main Menu? takes effect upon switching states or restarting the game.',
			NOT_FORCED,
			'' // ['foreverMenu', 'freakyMenu']
		],
		"Framerate Cap" => [120, Selector, 'Define your maximum FPS.', NOT_FORCED, ['']],
		'FPS Counter' => [true, Checkmark, 'Whether to display the FPS counter.', NOT_FORCED],
		'Memory Counter' => [
			true,
			Checkmark,
			'Whether to display approximately how much memory is being used.',
			NOT_FORCED
		],
		'State Object Count' => [
			false,
			Checkmark,
			'Whether to display how many objects there are on a Class / State.',
			NOT_FORCED
		],
		'Engine Mark' => [
			true,
			Checkmark,
			'Whether to display the Engine Watermark during Gameplay',
			NOT_FORCED
		],
		'Allow Console Window' => [
			true,
			Checkmark,
			'Whether to display a console window when F10 is pressed, useful for scripts.',
			NOT_FORCED
		],
		// USER INTERFACE;
		"UI Skin" => [
			'default',
			Selector,
			'Choose a UI Skin for judgements, combo, etc.',
			NOT_FORCED,
			''
		],
		'Judgement Stacking' => [
			true,
			Checkmark,
			"Whether Judgements should stack on top of eachother, also simplifies judgement / combo animations if disabled.",
			NOT_FORCED
		],
		'Fixed Judgements' => [
			true,
			Checkmark,
			"Fixes the judgements to the camera instead of to the world itself, making them easier to read.",
			NOT_FORCED
		],
		'Colored Health Bar' => [
			false,
			Checkmark,
			"Whether the Health Bar should follow the Character Icon colors.",
			NOT_FORCED
		],
		'Animated Score Color' => [
			true,
			Checkmark,
			"Whether the Score Bar should have an Animation for Hitting, based on your current ranking.",
			NOT_FORCED
		],
		'Counter' => [
			'None',
			Selector,
			'Choose whether you want somewhere to display your judgements, and where you want it.',
			NOT_FORCED,
			['None', 'Left', 'Right']
		],
		// NOTES AND HOLDS;
		"Note Skin" => [
			'default',
			Selector,
			'Choose a note skin, can also affect note splashes.',
			NOT_FORCED,
			''
		],
		'Arrow Opacity' => [60, Selector, "Set the opacity for your Strumline Notes.", NOT_FORCED],
		"Clip Style" => [
			'stepmania',
			Selector,
			"Chooses a style for hold note clippings; StepMania: Holds under Receptors; FNF: Holds over receptors",
			NOT_FORCED,
			['StepMania', 'FNF']
		],
		'No Camera Note Movement' => [
			false,
			Checkmark,
			'When enabled, left and right notes no longer move the camera.',
			NOT_FORCED
		],
		'Splash Opacity' => [
			80,
			Selector,
			"Set the opacity for your notesplashes, usually shown when hit a \"Sick!\" Judgement on Notes.",
			NOT_FORCED
		],
		"Opaque Holds" => [false, Checkmark, "Huh, why isnt the trail cut off?", NOT_FORCED],
		// ACCESSIBILITY;
		'Disable Antialiasing' => [
			false,
			Checkmark,
			'Whether to disable Anti-aliasing. Helps improve performance in FPS.',
			NOT_FORCED
		],
		'Disable Flashing Lights' => [
			false,
			Checkmark,
			"Whether flashing elements on the menus should be disabled.",
			NOT_FORCED
		],
		'Disable Shaders' => [
			false,
			Checkmark,
			"Whether to disable Fragment Shader effects during gameplay, can improve performance.",
			NOT_FORCED
		],
		'Reduced Movements' => [
			false,
			Checkmark,
			'Whether to reduce movements, like icons bouncing or beat zooms in gameplay.',
			NOT_FORCED
		],
		'Darkness Opacity' => [
			Checkmark,
			Selector,
			'Darkens non-ui elements, useful if you find the characters and backgrounds distracting.',
			NOT_FORCED
		],
		'Opacity Type' => [
			'World',
			Selector,
			'Choose where the Darkness Opacity Filter should be applied.',
			NOT_FORCED,
			['World', 'Notes']
		],
		'Filter' => [
			'none',
			Selector,
			'Choose a filter for colorblindness.',
			NOT_FORCED,
			['none', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		],
		// custom ones lol
		'Offset' => [Checkmark, 3],
	];

	public static var gameModifiers:Map<String, Dynamic> = [
		// GAMEPLAY;
		'Scroll Speed' => [false, Selector, NOT_FORCED],
		'Autoplay' => [false, Checkmark, NOT_FORCED],
		'Practice Mode' => [false, Checkmark, NOT_FORCED],
	];

	public static var trueSettings:Map<String, Dynamic> = [];
	public static var settingsDescriptions:Map<String, String> = [];

	public static var gameControls:Map<String, Dynamic> = [
		'LEFT' => [[FlxKey.LEFT, A], 0],
		'DOWN' => [[FlxKey.DOWN, S], 1],
		'UP' => [[FlxKey.UP, W], 2],
		'RIGHT' => [[FlxKey.RIGHT, D], 3],
		'ACCEPT' => [[FlxKey.SPACE, Z, FlxKey.ENTER], 6],
		'BACK' => [[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 7],
		'PAUSE' => [[FlxKey.ENTER, P], 8],
		'RESET' => [[R, R], 9],
		'UI_UP' => [[FlxKey.UP, W], 12],
		'UI_DOWN' => [[FlxKey.DOWN, S], 13],
		'UI_LEFT' => [[FlxKey.LEFT, A], 14],
		'UI_RIGHT' => [[FlxKey.RIGHT, D], 15],
		'DEBUG1' => [[SEVEN, SEVEN], 17],
		'DEBUG2' => [[EIGHT, EIGHT], 18],
	];

	public static var filters:Array<BitmapFilter> = []; // the filters the game has active
	/// initalise filters here
	public static var gameFilters:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
		"Deuteranopia" => {
			var matrix:Array<Float> = [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Protanopia" => {
			var matrix:Array<Float> = [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Tritanopia" => {
			var matrix:Array<Float> = [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		}
	];

	override public function create():Void
	{
		// load base game highscores and settings;
		PlayerSettings.init();
		Highscore.load();

		// load forever settings;
		loadControls();
		loadSettings();

		#if !html5
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end

		// apply saved filters
		FlxG.game.setFilters(filters);

		// Some additional changes to default HaxeFlixel settings, both for ease of debugging and usability.
		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start
		FlxGraphic.defaultPersist = true; // make sure we control all of the memory

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
		if (FlxG.save.data.comboOffset != null)
			comboOffset = FlxG.save.data.comboOffset;
		if (FlxG.save.data.ratingOffset != null)
			ratingOffset = FlxG.save.data.ratingOffset;

		CoolUtil.difficulties = CoolUtil.baseDifficulties.copy();

		Main.switchState(this, cast Type.createInstance(Main.initialState, []));
	}

	public static function loadSettings():Void
	{
		FlxG.save.bind('forever-settings', 'BeastlyGhost');

		// set the true settings array
		// only the first variable will be saved! the rest are for the menu stuffs

		// IF YOU WANT TO SAVE MORE THAN ONE VALUE MAKE YOUR VALUE AN ARRAY INSTEAD
		for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);

		// NEW SYSTEM, INSTEAD OF REPLACING THE WHOLE THING I REPLACE EXISTING KEYS
		// THAT WAY IT DOESNT HAVE TO BE DELETED IF THERE ARE SETTINGS CHANGES
		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				if (gameSettings.get(singularSetting) != null && gameSettings.get(singularSetting)[3] != FORCED)
					trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}

		// lemme fix that for you
		if (!Std.isOfType(trueSettings.get("Framerate Cap"), Int)
			|| trueSettings.get("Framerate Cap") < 30
			|| trueSettings.get("Framerate Cap") > 360)
			trueSettings.set("Framerate Cap", 30);

		var similarSettings:Array<String> = ["Darkness Opacity", "Hitsound Volume", "Arrow Opacity", "Splash Opacity"];

		for (i in similarSettings)
		{
			var defaultValue = 100;
			switch (i)
			{
				case 'Darkness Opacity':
					defaultValue = 0;
				case "Hitsound Volume":
					defaultValue = 0;
				case "Arrow Opacity":
					defaultValue = 60;
				case "Splash Opacity":
					defaultValue = 80;
			}
			if (!Std.isOfType(trueSettings.get(i), Int) || trueSettings.get(i) < 0 || trueSettings.get(i) > 100)
				trueSettings.set(i, defaultValue);
		}

		// 'hardcoded' ui skins
		gameSettings.get("UI Skin")[4] = CoolUtil.returnAssetsLibrary('UI');
		if (!gameSettings.get("UI Skin")[4].contains(trueSettings.get("UI Skin")))
			trueSettings.set("UI Skin", 'default');

		gameSettings.get("Note Skin")[4] = CoolUtil.returnAssetsLibrary('noteskins/notes');
		if (!gameSettings.get("Note Skin")[4].contains(trueSettings.get("Note Skin")))
			trueSettings.set("Note Skin", 'default');

		gameSettings.get("Hitsound Type")[4] = CoolUtil.returnAssetsLibrary('hitsounds', 'assets/sounds');
		if (!gameSettings.get("Hitsound Type")[4].contains(trueSettings.get("Hitsound Type")))
			trueSettings.set("Hitsound Type", 'default');

		gameSettings.get("Menu Song")[4] = CoolUtil.returnAssetsLibrary('menus', 'assets/music');
		if (!gameSettings.get("Menu Song")[4].contains(trueSettings.get("Menu Song")))
			trueSettings.set("Menu Song", 'freakyMenu');

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
		if (FlxG.save.data.comboOffset != null)
			comboOffset = FlxG.save.data.comboOffset;
		if (FlxG.save.data.ratingOffset != null)
			ratingOffset = FlxG.save.data.ratingOffset;

		saveSettings();
		updateAll();
	}

	public static function saveSettings():Void
	{
		// ez save lol
		FlxG.save.bind('forever-settings', 'BeastlyGhost');
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		#if DEBUG_TRACES trace('Settings Saved!'); #end
		updateAll();
	}

	public static function saveControls():Void
	{
		FlxG.save.bind('forever-controls', 'BeastlyGhost');
		FlxG.save.data.controls = gameControls;
		FlxG.save.flush();

		#if DEBUG_TRACES trace('Controls Saved!'); #end
	}

	public static function loadControls():Void
	{
		FlxG.save.bind('forever-controls', 'BeastlyGhost');
		if (FlxG.save != null && FlxG.save.data.controls != null)
		{
			if ((FlxG.save.data.controls != null) && (Lambda.count(FlxG.save.data.controls) == Lambda.count(gameControls)))
				gameControls = FlxG.save.data.controls;
		}

		saveControls();
	}

	public static function updateAll()
	{
		FlxG.autoPause = trueSettings.get('Auto Pause');

		Overlay.updateDisplayInfo(trueSettings.get('FPS Counter'), trueSettings.get('State Object Count'), trueSettings.get('Memory Counter'),
			trueSettings.get('Forever Mark'));

		#if !html5
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end

		///*
		filters = [];
		FlxG.game.setFilters(filters);

		var theFilter:String = trueSettings.get('Filter');
		if (theFilter != 'none' && gameFilters.get(theFilter) != null)
		{
			var realFilter = gameFilters.get(theFilter).filter;

			if (realFilter != null)
				filters.push(realFilter);
		}
		FlxG.game.setFilters(filters);
	}
}
