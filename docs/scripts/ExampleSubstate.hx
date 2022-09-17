package;

var subBG:FlxSprite;
var text:FlxText;

function postCreate()
{
    trace('Initialized Base Script');
}

function update(elapsed:Float)
{
    if (FlxG.keys.justPressed.U)
    {
        game.paused = true;
        openSubState(new ScriptedSubstate('test'));
    }
}

function substateCreate()
{
    trace('Generated Custom Substate.');

	subBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	subBG.scrollFactor.set();
    subBG.alpha = 0;
    subBG.cameras = [PlayState.strumHUD];
	game.add(subBG);

    text = new FlxText(0, 0, 0, 'This is\nan Example\nCustom Substate\nusing hscript!', 64);
    text.screenCenter(FlxAxes.X, FlxAxes.Y);
    text.scrollFactor.set();
	text.cameras = [PlayState.strumHUD];
    game.add(text);

	FlxTween.tween(subBG, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
}

function substatePostCreate()
{
    trace('Post Create on Scripted Substate.');
}

function substateUpdate(elapsed:Float)
{
    //trace('Custom Substate Update.');

    if (FlxG.keys.justPressed.ESCAPE)
    {
        close();
    }
}

function substatePostUpdate(elapsed:Float)
{
    //trace('Post Custom Substate Update.');
}

function substateDestroy()
{
    trace('Custom Substate Destroyed.');
    game.remove(subBG);
    game.remove(text);
    game.paused = false;
}