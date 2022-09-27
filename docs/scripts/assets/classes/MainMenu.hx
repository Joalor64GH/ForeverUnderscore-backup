// customized menu example
// for all your custom menu needs
// WORK IN PROGRESS

/*
== FUNCTIONS ==

create()
overrideCreate()
postCreate()

optionSetup()
postOptionSetup()

update(elapsed:Float)
overrideUpdate(elapsed:Float)
postUpdate(elapsed:Float)

updateSelection()
overrideUpdateSelection()
postUpdateSelection()

beatHit(curBeat:Int)
stepHit(curStep:Int)

stateSwitch()
postStateSwitch()

NOTICE: "override" functions will stop the original one, so you can add your own parameters to them
they also make "post" functions not work at all if used

== VARS ==

MainMenuState (example use: MainMenuState.bg.kill();)
menuItem (only works inside optionSetup() or postOptionSetup())
*/

import lime.app.Application;

var newbg:FlxSprite;
var checkers:FlxBackdrop;
var topBar:FlxSprite;
var bottomBar:FlxSprite;
var topMarker:FlxText;
var bottomMarker:FlxText;
var boyfriend:Character;

function create()
{
	newbg = new FlxSprite(-80).loadGraphic(Paths.image('menus/base/menuBGBlue'));
	newbg.scrollFactor.set(0, 0.18);
	newbg.setGraphicSize(Std.int(newbg.width * 1.175));
	newbg.updateHitbox();
	newbg.screenCenter();
	newbg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
	add(newbg);

	checkers = new FlxBackdrop(null, 1, 1, true, true, 1, 1).loadGraphic(Paths.image('menus/chart editor/grid'));
	checkers.alpha = 0.5;
	checkers.updateHitbox();
	checkers.velocity.set(100, 100);
	add(checkers);
	
	topBar = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
	topBar.setGraphicSize(FlxG.width, 48);
	topBar.updateHitbox();
	topBar.screenCenter(FlxAxes.X);

	bottomBar = new FlxSprite().loadGraphic(topBar.graphic);
	bottomBar.setGraphicSize(FlxG.width, 48);
	bottomBar.updateHitbox();
	bottomBar.screenCenter(FlxAxes.X);

	add(topBar);
	topBar.y -= topBar.height;
	add(bottomBar);
	bottomBar.y += FlxG.height;

	topMarker = new FlxText(8, 8, 0, "[CUSTOM SCRIPTED MENU STATE EXAMPLE]").setFormat(Paths.font('vcr.ttf'), 32, 0xFFFFFFFF);
	topMarker.alpha = 0;
	topMarker.velocity.set(100, 0);
	topMarker.scrollFactor.set();
	add(topMarker);

	bottomMarker = new FlxText(8, 8, 0, "[FNF v" + Application.current.meta.get('version') + " | FOREVER ENGINE v" + Main.foreverVersion + " | UNDERSCORE v" + Main.underscoreVersion + "]").setFormat(Paths.font('vcr.ttf'), 32, 0xFFFFFFFF);
	bottomMarker.alpha = 0;
	add(bottomMarker);

	topBar.cameras = [MainMenuState.camHUD];
	bottomBar.cameras = [MainMenuState.camHUD];
	topMarker.cameras = [MainMenuState.camHUD];
	bottomMarker.cameras = [MainMenuState.camHUD];
	
	FlxTween.tween(topMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
	FlxTween.tween(bottomMarker, {alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.6});
}

function postCreate()
{
	MainMenuState.bg.kill();
	MainMenuState.bg.destroy();
	MainMenuState.camFollow.active = false;
	MainMenuState.forceCenter = false;
	FlxG.camera.follow(null, null, null);
	boyfriend = new Character(30, 250, true, 'bf-psych');
	boyfriend.cameras = [MainMenuState.camHUD];
	boyfriend.flipX = true;
	add(boyfriend);
}

function postOptionSetup()
{
	switch (menuItem.ID)
	{
		case 0: menuItem.x = FlxG.width * 0.43;
		case 1: menuItem.x = FlxG.width * 0.43;
		case 2: menuItem.x = FlxG.width * 0.43;
		case 3: menuItem.x = FlxG.width * 0.43;
	}
}

function postUpdate(elapsed:Float)
{
	boyfriend.dance();
	topBar.y = FlxMath.lerp(topBar.y, 0, elapsed * 6);
	bottomBar.y = FlxMath.lerp(bottomBar.y, FlxG.height - bottomBar.height, elapsed * 6);
	topMarker.y = topBar.y + 5;
	bottomMarker.y = bottomBar.y + 5;
	topMarker.screenCenter(FlxAxes.X);
	bottomMarker.screenCenter(FlxAxes.X);
}

function stateSwitch()
{
	boyfriend.playAnim('hey');
	boyfriend.specialAnim = true;
}
