var limo:FNFSprite;
var grpLimoDancers:FlxSpriteGroup;

function generateStage()
{
    curStage = 'highway';
    PlayState.defaultCamZoom = 0.90;

    var skyBG:FNFSprite = new FNFSprite(-120, -50).loadGraphic(Paths.image('backgrounds/' + curStage + '/limoSunset'));
    skyBG.scrollFactor.set(0.1, 0.1);
    add(skyBG);

    var bgLimo:FNFSprite = new FNFSprite(-200, 480);
    bgLimo.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/bgLimo');
    bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
    bgLimo.animation.play('drive');
    bgLimo.scrollFactor.set(0.4, 0.4);
    add(bgLimo);

    grpLimoDancers = new FlxSpriteGroup();
    add(grpLimoDancers);

    for (i in 0...5)
    {
        var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
        dancer.scrollFactor.set(0.4, 0.4);
        grpLimoDancers.add(dancer);
    }

    var limoTex = Paths.getSparrowAtlas('backgrounds/' + curStage + '/limoDrive');

    limo = new FNFSprite(-120, 550);
    limo.frames = limoTex;
    limo.animation.addByPrefix('drive', "Limo stage", 24);
    limo.animation.play('drive');
    limo.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
    layers.add(limo);

    fastCar = new FNFSprite(-300, 160).loadGraphic(Paths.image('backgrounds/' + curStage + '/fastCarLol'));
}

function repositionPlayers(boyfriend:Character, dad:Character, gf:Character)
{
	boyfriend.y -= 220;
	boyfriend.x += 260;
}

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
{
    grpLimoDancers.forEach(function(dancer:BackgroundDancer)
    {
        dancer.dance();
    });
}