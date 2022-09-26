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

NOTICE: "override" functions will stop the original one, so you can add your own parameters to them
they also make "post" functions not work at all if used

== VARS ==

MainMenuState (example use: MainMenuState.bg.kill();)
menuItem (only works inside optionSetup() or postOptionSetup())
*/

var newbg:FlxSprite;

function create()
{
	//MainMenuState.optionShit = ['freeplay', 'credits', 'options'];
	newbg = new FlxSprite(-80).loadGraphic(Paths.image('menus/base/menuDesat'));
	newbg.scrollFactor.set(0, 0.18);
	newbg.setGraphicSize(Std.int(newbg.width * 1.175));
	newbg.updateHitbox();
	newbg.screenCenter();
	newbg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
	add(newbg);
}

function postCreate()
{
	MainMenuState.bg.kill();
	MainMenuState.bg.destroy();
	MainMenuState.forceCenter = false;
}

function postOptionSetup()
{
	menuItem.x = 10;
}