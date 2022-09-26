// customized menu example
// for all your custom menu needs
// WORK IN PROGRESS

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