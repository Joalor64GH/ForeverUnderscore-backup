package base.debug;

import base.debug.OverlayOutline;
import haxe.Timer;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	Overlay that displays FPS and memory usage.

	Based on this tutorial:
	https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
**/
class Overlay extends TextField
{
	var times:Array<Float> = [];
	var memPeak:UInt = 0;

	public var overlayOutline:Bitmap;

	// display info
	static var displayFps = true;
	static var displayMemory = true;
	static var displayExtra = true;
	static var displayForever = true;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = x;

		autoSize = LEFT;
		selectable = false;

		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 18, 0xFFFFFF);
		text = "";

		addEventListener(Event.ENTER_FRAME, update);

		/*overlayOutline = OverlayOutline.renderImage(this, 1, 0x000000, 1, true);
		cast(Lib.current.getChildAt(0), Main).addChild(overlayOutline);*/
	}

	static final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB'];

	public static function getInterval(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		while (size > 1024 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		return size + " " + intervalArray[data];
	}

	function update(_:Event)
	{
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		var mem = System.totalMemory;
		if (mem > memPeak)
			memPeak = mem;

		if (visible)
		{
			text = '' // set up the text itself
				+ (displayFps ? times.length + " FPS\n" : '') // Framerate
			#if !neko + (displayExtra ? Main.mainClassState + "\n" : '') #end // Current Game State
			+ (displayMemory ? '${getInterval(mem)} / ${getInterval(memPeak)}\n' : '') // Current and Total Memory Usage
			+ (displayForever ? 'FE Underscore v' + Main.underscoreVersion : ''); // Engine Watermark Display
		}

		//addOutline();
	}

	function addOutline()
	{
		Main.instance.removeChild(overlayOutline);
		overlayOutline = OverlayOutline.renderImage(this, 2, 0x000000, 1);
		Main.instance.addChild(overlayOutline);
	}

	public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayExtra:Bool, shouldDisplayMemory:Bool, shouldDisplayForever:Bool)
	{
		displayFps = shouldDisplayFps;
		displayExtra = shouldDisplayExtra;
		displayMemory = shouldDisplayMemory;
		displayForever = shouldDisplayForever;
	}
}
