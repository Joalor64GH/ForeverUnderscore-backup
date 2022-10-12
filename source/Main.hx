package;

import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import base.debug.Overlay;
import dependency.Discord;
import dependency.FNFTransition;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;

// Here we actually import the states and metadata, and just the metadata.
// It's nice to have modularity so that we don't have ALL elements loaded at the same time.
// at least that's how I think it works. I could be stupid!
class Main extends Sprite
{
	public static var defaultFramerate = 120;

	public static var initialState:Class<FlxState> = states.TitleState; // specify the state where the game should start at;

	public static final foreverVersion:String = '0.3.1'; // current forever engine version;
	public static final underscoreVersion:String = '0.2.3'; // current forever engine underscore version;

	public static var commitHash:Null<String>; // commit hash, for github builds;

	public static var overlay:Overlay; // info counter that usually appears at the top left corner;
	public static var console:Console; // console that appears when you press F10 (if allowed);

	public static var letterOffset:Bool = false; // alphabet offset workaround idk;

	// calls a function to set the game up
	public function new()
	{
		super();

		commitHash = returnGitHash();

		SUtil.uncaughtErrorHandler();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		FlxTransitionableState.skipNextTransIn = true;

		SUtil.check();

		addChild(new FlxGame(0, 0, Init, 1, 120, 120, true));

		// begin the discord rich presence
		#if DISCORD_RPC
		if (Init.getSetting('Discord Rich Presence'))
		{
			Discord.initializeRPC();
			Discord.changePresence('');
		}
		#end

		#if desktop
		overlay = new Overlay(0, 0);
		addChild(overlay);

		console = new Console();
		addChild(console);
		#end
	}

	public static function framerateAdjust(input:Float)
	{
		return input * (60 / FlxG.drawFramerate);
	}

	/*
		This is used to switch "rooms," to put it basically. Imagine you are in the main menu, and press the freeplay button.
		That would change the game's main class to freeplay, as it is the active class at the moment.
	 */
	public static function switchState(curState:FlxState, target:FlxState)
	{
		// Custom made Trans in
		if (!FlxTransitionableState.skipNextTransIn)
		{
			curState.openSubState(new FNFTransition(0.35, false));
			FNFTransition.finishCallback = function()
			{
				FlxG.switchState(target);
			};
			return #if DEBUG_TRACES trace('changed state') #end;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;
		// load the state
		FlxG.switchState(target);
	}

	public static function updateFramerate(newFramerate:Int)
	{
		// flixel will literally throw errors at me if I dont separate the orders
		if (newFramerate > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else
		{
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "crash/" + "FE-U_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the GitHub page"
			+ "\nhttps://github.com/BeastlyGhost/Forever-Engine-Underscore"
			+ "\n\nCrash Handler written by: sqirra-rng\n"
			+ "\nForever Engine Underscore v"
			+ Main.underscoreVersion
			+ (commitHash.length > 2 ? '${commitHash}' : '')
			+ "\n";

		try // to make the game not crash if it can't save the crash file
		{
			if (!FileSystem.exists("crash"))
				FileSystem.createDirectory("crash");

			File.saveContent(path, errMsg + "\n");
		}

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "FE-CrashDialog";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (FileSystem.exists(crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}

		#if DISCORD_RPC
		Discord.shutdownRPC();
		#end
		Sys.exit(1);
	}

	public static function returnGitHash()
	{
		var process = new sys.io.Process('git', ['rev-parse', 'HEAD']);

		var commitHash:String;

		try // read the output of the process
		{
			commitHash = process.stdout.readLine();
		}
		catch (e) // leave it as blank in the event of an error
		{
			commitHash = '';
		}
		var trimmedCommitHash:String = commitHash.substr(0, 7);

		// Generates a string expression
		return ' (' + trimmedCommitHash + ')';
	}
}
