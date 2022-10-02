var limo:FNFSprite;
var grpLimoDancers:FlxSpriteGroup;

function generateStage()
{
    curStage = 'highway';

    var skyBG:FNFSprite = new FNFSprite(-120, -50).loadGraphic(Paths.image('limoSunset', 'stages/' + curStage + '/images'));
    skyBG.scrollFactor.set(0.1, 0.1);
    add(skyBG);

    var bgLimo:FNFSprite = new FNFSprite(-200, 480);
    bgLimo.frames = Paths.getSparrowAtlas('bgLimo', 'stages/' + curStage + '/images');
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

    var limoTex = Paths.getSparrowAtlas('limoDrive', 'stages/' + curStage + '/images');

    limo = new FNFSprite(-120, 550);
    limo.frames = limoTex;
    limo.animation.addByPrefix('drive', "Limo stage", 24);
    limo.animation.play('drive');
    limo.antialiasing = !Init.getSetting('Disable Antialiasing');
    layers.add(limo);

    fastCar = new FNFSprite(-300, 160).loadGraphic(Paths.image('fastCarLol', 'stages/' + curStage + '/images'));
}

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
{
    grpLimoDancers.forEach(function(dancer:BackgroundDancer)
    {
        dancer.dance();
    });
}