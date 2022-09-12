var phillyTrain:FNFSprite;
var trainSound:FlxSound;
var phillyCityLights:FlxSpriteGroup;

var trainFrameTiming:Float = 0;
var trainCars:Int = 8;
var trainCooldown:Int = 0;

var curLight:Int = 0;

var startedMoving:Bool = false;
var trainMoving:Bool = false;
var trainFinishing:Bool = false;

function generateStage()
{
    curStage = 'philly';
    PlayState.defaultCamZoom = 1.05;

    var bg:FNFSprite = new FNFSprite(-100).loadGraphic(Paths.image('backgrounds/' + curStage + '/sky'));
    bg.scrollFactor.set(0.1, 0.1);
    add(bg);

    var city:FNFSprite = new FNFSprite(-10).loadGraphic(Paths.image('backgrounds/' + curStage + '/city'));
    city.scrollFactor.set(0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    add(city);

    phillyCityLights = new FlxSpriteGroup();
    add(phillyCityLights);

    for (i in 0...5)
    {
        var light:FNFSprite = new FNFSprite(city.x).loadGraphic(Paths.image('backgrounds/' + curStage + '/win' + i));
        light.scrollFactor.set(0.3, 0.3);
        light.visible = false;
        light.setGraphicSize(Std.int(light.width * 0.85));
        light.updateHitbox();
        light.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
        phillyCityLights.add(light);
    }

    var streetBehind:FNFSprite = new FNFSprite(-40, 50).loadGraphic(Paths.image('backgrounds/' + curStage + '/behindTrain'));
    add(streetBehind);

    phillyTrain = new FNFSprite(2000, 360).loadGraphic(Paths.image('backgrounds/' + curStage + '/train'));
    add(phillyTrain);

    trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
    FlxG.sound.list.add(trainSound);

    var street:FNFSprite = new FNFSprite(-40, streetBehind.y).loadGraphic(Paths.image('backgrounds/' + curStage + '/street'));
    add(street);
}

function trainStart()
{
    trainMoving = true;
    if (!trainSound.playing)
        trainSound.play(true);
}

function updateTrainPos(gf:Character)
{
    if (trainSound.time >= 4700)
    {
        startedMoving = true;
        gf.playAnim('hairBlow');
    }

    if (startedMoving)
    {
        phillyTrain.x -= 400;

        if (phillyTrain.x < -2000 && !trainFinishing)
        {
            phillyTrain.x = -1150;
            trainCars -= 1;

            if (trainCars <= 0)
                trainFinishing = true;
        }

        if (phillyTrain.x < -4000 && trainFinishing)
            trainReset(gf);
    }
}

function trainReset(gf:Character)
{
    gf.playAnim('hairFall');
    phillyTrain.x = FlxG.width + 200;
    trainMoving = false;
    trainCars = 8;
    trainFinishing = false;
    startedMoving = false;
}

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
{
    if (!trainMoving)
        trainCooldown += 1;

    if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
    {
        trainCooldown = FlxG.random.int(-4, 0);
        trainStart();
    }

    if (curBeat % 4 == 0)
    {
        var lastLight:FlxSprite = phillyCityLights.members[0];

        phillyCityLights.forEach(function(light:FNFSprite)
        {
            // Take note of the previous light
            if (light.visible == true)
                lastLight = light;

            light.visible = false;
        });

        // To prevent duplicate lights, iterate until you get a matching light
        while (lastLight == phillyCityLights.members[curLight])
        {
            curLight = FlxG.random.int(0, phillyCityLights.length - 1);
        }

        phillyCityLights.members[curLight].visible = true;
        phillyCityLights.members[curLight].alpha = 1;

        FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.stepCrochet * .016);
    }
}

function updateStageConst(elapsed:Float, boyfriend:Character, gf:Character, dadOpponent:Character)
{
    if (trainMoving)
    {
        trainFrameTiming += elapsed;

        if (trainFrameTiming >= 1 / 24)
        {
            updateTrainPos(gf);
            trainFrameTiming = 0;
        }
    }
}