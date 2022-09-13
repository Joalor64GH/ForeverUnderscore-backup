function generateStage()
{
	/**
	 * hello, just wanna make it clear that you need to add your stage images to the
	 * assets/backgrounds/<stageName> folder for it to appear on the chart editor
	 * the stageName in this case is `exampleStage`
	 * so my folder would be `assets/backgrounds/exampleStage/`
	**/

	curStage = 'stage';
    PlayState.defaultCamZoom = 0.9;
    spawnGirlfriend(true);

	// create stage graphics just haxe code!

	var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.9, 0.9);
    bg.active = false;
    add(bg);

    var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
    stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
    stageFront.updateHitbox();
    stageFront.antialiasing = true;
    stageFront.scrollFactor.set(0.9, 0.9);
    stageFront.active = false;
    add(stageFront);

    var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
    stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
    stageCurtains.updateHitbox();
    stageCurtains.antialiasing = true;
    stageCurtains.scrollFactor.set(1.3, 1.3);
    stageCurtains.active = false;
    add(stageCurtains);
}

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	// similar to beatHit, this function is used for stage updates *on beats*;
}

function updateStageSteps(curStep:Int, boyfriend:Character, gf:Character, dad:Character)
{
	// similar to stepHit, this function is used for stage updates *on steps*;
}

function repositionPlayers(boyfriend:Character, gf:Character, dad:Character)
{
	// boyfriend.x += 0;
	// boyfriend.y += 0;
	// gf.x += 0;
	// gf.y += 0;
	// dad.x += 0;
	// dad.y += 0;
}