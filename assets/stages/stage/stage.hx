var cameraTwn:FlxTween;

function tweenCamIn()
{
	if (PlayState.SONG.song.toLowerCase() == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
	{
		cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.1}, (Conductor.stepCrochet * 4 / 1000), {
			ease: FlxEase.elasticInOut,
			onComplete: function(twn:FlxTween)
			{
				cameraTwn = null;
			}
		});
	}
}

function generateStage()
{
	curStage = 'stage';

	var stageDir:String = 'stages/' + curStage + '/images';

	var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('stageback', stageDir));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.9, 0.9);
	bg.active = false;
	add(bg);

	var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('stagefront', stageDir));
	stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
	stageFront.updateHitbox();
	stageFront.antialiasing = true;
	stageFront.scrollFactor.set(0.9, 0.9);
	stageFront.active = false;
	add(stageFront);

	var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', stageDir));
	stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	stageCurtains.updateHitbox();
	stageCurtains.antialiasing = true;
	stageCurtains.scrollFactor.set(1.3, 1.3);
	stageCurtains.active = false;
	add(stageCurtains);
}

function dadPosition(boyfriend:Character, gf:Character, dad:Character, camPos:FlxPoint)
{
	if (dad.curCharacter == 'gf')
	{
		dad.setPosition(gf.x, gf.y);
		gf.visible = false;
		if (PlayState.isStoryMode)
		{
			camPos.x += 600;
			tweenCamIn();
		}
	}
}
